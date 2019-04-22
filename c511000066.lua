--Jester's Panic
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFacedown() and c:IsDestructable()
end
function s.costfilter1(c)
	return c:IsType(TYPE_SPELL) and not c:IsPublic()
end
function s.costfilter2(c)
	return c:IsType(TYPE_TRAP) and not c:IsPublic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_SZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_SZONE,1,1,nil)
end
function s.dfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsLevelBelow(2) and c:IsRace(RACE_SPELLCASTER)
		and not c:IsHasEffect(EFFECT_CANNOT_ATTACK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFacedown() then
		Duel.ConfirmCards(tp,tc)
		if tc:IsType(TYPE_SPELL) then 
			if Duel.IsExistingMatchingCard(s.costfilter1,tp,LOCATION_HAND,0,1,nil) then
				local g=Duel.SelectMatchingCard(tp,s.costfilter1,tp,LOCATION_HAND,0,1,1,nil)
				Duel.ConfirmCards(1-tp,g)
				Duel.ShuffleHand(tp)
				if Duel.Destroy(tc,REASON_EFFECT)>0 then
					local dg=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_MZONE,0,nil)
					local tg=dg:GetFirst()
					while tg do
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_DIRECT_ATTACK)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					tg:RegisterEffect(e1)
					tg=dg:GetNext()
					end
				end
			end
		end
		if tc:IsType(TYPE_TRAP) then
			if Duel.IsExistingMatchingCard(s.costfilter2,tp,LOCATION_HAND,0,1,nil) then
				local g=Duel.SelectMatchingCard(tp,s.costfilter2,tp,LOCATION_HAND,0,1,1,nil)
				Duel.ConfirmCards(1-tp,g)
				Duel.ShuffleHand(tp)
				if Duel.Destroy(tc,REASON_EFFECT)>0 then
					local dg=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_MZONE,0,nil)
					local tg=dg:GetFirst()
					while tg do
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_DIRECT_ATTACK)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					tg:RegisterEffect(e1)
					tg=dg:GetNext()
					end
				end
			end
		end
	end
end
function s.attg(e,c,tp,eg,ep,ev,re,r,rp)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsLevelBelow(2) and c:IsRace(RACE_SPELLCASTER)
		and not c:IsHasEffect(EFFECT_CANNOT_ATTACK) and not not Duel.IsExistingMatchingCard(c511000060.filter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack())
end