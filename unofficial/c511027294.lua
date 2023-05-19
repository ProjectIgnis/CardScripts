--光子化 (Anime)
--Lumenize (Anime)
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_NEGATE + CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetAttacker():IsControler(1-tp)
end
function s.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_MZONE, 0, 1, nil)
        and Duel.GetAttacker():IsControler(1-tp) end
    Duel.SetTargetCard(Duel.SelectMatchingCard(tp, Card.IsFaceup, tp, LOCATION_MZONE, 0, 1, 1, nil))
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, Duel.GetAttacker(), 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_ATKCHANGE, Duel.GetAttacker(), 1, 0, 0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc = Duel.GetFirstTarget()
    local atk = Duel.GetAttacker():GetAttack()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.NegateAttack()
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(atk)
        tc:RegisterEffect(e1)
    end
end
