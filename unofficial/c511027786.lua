--暴風雨レインストーム (Anime)
--Rain Storm (Anime)
--Made by When
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
function s.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x18) and c:IsAttackAbove(1000)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    local atk=tc:GetAttack()
    if atk<=0 then return end
    local gc=0
    local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
    if ct==1 then
        gc=1
    else
        local t={}
        local l=1
        while atk>0 and ct>0 do
            atk=atk-1000
            ct=ct-1
            t[l]=l
            l=l+1
        end
        Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
        gc=Duel.AnnounceNumber(tp,table.unpack(t))
        repeat
        local g=Duel.SelectMatchingCard(tp,nil,0,0,LOCATION_ONFIELD,1,1,nil)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-1000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        Duel.Destroy(g,REASON_EFFECT) 
        gc=gc-1
        until gc<=0
    end
end