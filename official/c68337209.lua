--Ｍ∀ＬＩＣＥ ＩＮ ＵＮＤＥＲＧＲＯＵＮＤ
--Maliss in Underground
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--While you have 3 or more banished "Maliss" Traps with different names, "Maliss" Link Monsters you control gain 3000 ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.atkupcon)
	e2:SetTarget(function(e,c) return s.atkfilter(c) end)
	e2:SetValue(3000)
	c:RegisterEffect(e2)
	--While you control any "Maliss" Link Monsters, your opponent's monsters can only target those monsters for attacks
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.atktgcon)
	e3:SetValue(function(e,c) return not s.atkfilter(c) end)
	c:RegisterEffect(e3)
end
s.listed_series={SET_MALISS}
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.rmfilter(c)
	return c:IsSetCard(SET_MALISS) and c:IsAbleToRemove()
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
function s.atkfilter(c)
	return c:IsSetCard(SET_MALISS) and c:IsType(TYPE_LINK) and c:IsFaceup()
end
function s.atkupconfilter(c)
	return c:IsSetCard(SET_MALISS) and c:IsTrap() and c:IsFaceup()
end
function s.atkupcon(e)
	local g=Duel.GetMatchingGroup(s.atkupconfilter,e:GetHandlerPlayer(),LOCATION_REMOVED,0,nil)
	return g:GetClassCount(Card.GetCode)>=3
end
function s.atktgcon(e)
	return Duel.IsExistingMatchingCard(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) 
end