/*
Copyright (c) 2013 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

Author: Leonardo de Moura
*/
#pragma once
#include <memory>
#include "environment.h"
#include "formatter.h"

namespace lean {
/**
   \brief Expression elaborator, it is responsible for "filling" holes
   in terms left by the user. This is the main module resposible for computing
   the value of implicit arguments.
*/
class elaborator {
    class imp;
    std::shared_ptr<imp> m_ptr;
    static void print(imp * ptr);
public:
    explicit elaborator(environment const & env);
    ~elaborator();

    expr mk_metavar();

    expr operator()(expr const & e);

    /**
        \brief If \c e is an expression instantiated by the elaborator, then it
        returns the expression (the one with "holes") used to generate \c e.
        Otherwise, it just returns \c e.
    */
    expr const & get_original(expr const & e) const;

    void set_interrupt(bool flag);
    void interrupt() { set_interrupt(true); }
    void reset_interrupt() { set_interrupt(false); }

    void clear();

    environment const & get_environment() const;

    void display(std::ostream & out) const;
    format pp(formatter & f, options const & o) const;
};
/** \brief Return true iff \c e is a special constant used to mark application of overloads. */
bool is_overload_marker(expr const & e);
/** \brief Return the overload marker */
expr mk_overload_marker();
}
