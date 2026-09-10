--幻げん木ぼく龍りゅう (Anime)
--Mythic Tree Dragon (Anime)
--Made by When
local s,id=GetID()
function s.initial_effect(c)
	--Double Level
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LVCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
        return Duel.IsExistingMatchingCard(aux.FaceupFilter(s.cfilter),tp,LOCATION_MZONE,0,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
	    local e1=Effect.CreateEffect(c)
	    e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetRange(LOCATION_MZONE)
	    e1:SetCode(EFFECT_CHANGE_LEVEL)
	    e1:SetValue(c:GetLevel()*2)
	    e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
	    c:RegisterEffect(e1)
	end
end
