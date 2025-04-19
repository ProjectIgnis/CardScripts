--エンシェント・シャーク ハイパー・メガロドン (Anime)
--Hyper-Ancient Shark Megalodon (Anime)
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
    --Summon with 1 tribute
    local e0=aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),s.otfilter)
    --Destroy opponent's monsters with ATK less than or equal to damage opponent would have taken
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
end
function s.otfilter(c,tp)
    return c:IsAttribute(ATTRIBUTE_WATER) and (c:IsControler(tp) or c:IsFaceup())
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsAttackBelow,tp,0,LOCATION_MZONE,nil,ev)
    if ep~=tp and Duel.SelectEffectYesNo(tp,e:GetHandler()) and Duel.Destroy(g,REASON_EFFECT+REASON_REPLACE) then
        Duel.ChangeBattleDamage(1-tp,0)
    end
end