--竜絶蘭
--Dragon Agave
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.NOT(aux.FilterBoolFunctionEx(Card.IsType,TYPE_TOKEN)),2)
	--apply effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,RACE_DRAGON+RACE_DINOSAUR+RACE_SEASERPENT+RACE_WYRM)
	if chk==0 then return #g>0 and (g:FilterCount(Card.IsRace,nil,RACE_SEASERPENT)<#g or Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)) end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:FilterCount(Card.IsRace,nil,RACE_DRAGON)*100)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:FilterCount(Card.IsRace,nil,RACE_WYRM)*400)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,RACE_DRAGON+RACE_DINOSAUR+RACE_SEASERPENT+RACE_WYRM)
	if #g==0 then return end
	local c=e:GetHandler()
	local ct1=g:FilterCount(Card.IsRace,nil,RACE_DRAGON)
	local ct2=g:FilterCount(Card.IsRace,nil,RACE_DINOSAUR)
	local ct3=g:FilterCount(Card.IsRace,nil,RACE_SEASERPENT)
	local ct4=g:FilterCount(Card.IsRace,nil,RACE_WYRM)
	if ct1>0 then
		Duel.Damage(1-tp,ct1*100,REASON_EFFECT)
	end
	if ct2>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct2*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	local og=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if ct3>0 and #og>0 then
		for tc in aux.Next(og) do
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(ct3*-300)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
	if ct4>0 then
		Duel.Recover(tp,ct4*400,REASON_EFFECT)
	end
end

