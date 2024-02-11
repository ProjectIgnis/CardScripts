--Behold, Gate Guardian!
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_names={25833572,25955164,62340868,98434877}
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(25955164,62340868,98434877)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(tp,id)==0 and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--OPD register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Shuffle entire hand, add 1 Level 11 monster and Special Summon Level 7 monsters
	local c=e:GetHandler()
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.SendtoDeck(hg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if Duel.SendtoHand(tc,tp,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,tc)
		if Duel.SelectYesNo(tp,aux.Stringid(id,0)) and ft>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) then
			if ft>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=2 end
			if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
			local sg=aux.SelectUnselectGroup(rg,e,tp,1,ft,s.check,1,tp,HINTMSG_SPSUMMON)
			for sc in sg:Iter() do
				Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
				--ATK/DEF become 0
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_ATTACK_FINAL)
				e1:SetRange(LOCATION_MZONE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
				e1:SetValue(0)
				sc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
				sc:RegisterEffect(e2)
				--Negate effects
				local e3=e1:Clone()
				e3:SetCode(EFFECT_DISABLE_EFFECT)
				sc:RegisterEffect(e3)
			end
			Duel.SpecialSummonComplete()
		end
	end
	--Gate Guardian gains Suijin/Kazejin/Sanga effect
	local ea=Effect.CreateEffect(c)
	ea:SetDescription(aux.Stringid(id,0))
	ea:SetCategory(CATEGORY_ATKCHANGE)
	ea:SetType(EFFECT_TYPE_QUICK_O)
	ea:SetRange(LOCATION_MZONE)
	ea:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	ea:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	ea:SetCountLimit(1)
	ea:SetCondition(s.condition)
	ea:SetTarget(s.target)
	ea:SetOperation(s.operation)
	local eb=Effect.CreateEffect(c)
	eb:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	eb:SetRange(0x5f)
	eb:SetTargetRange(LOCATION_MZONE,0)
	eb:SetTarget(function(e,c) return c:IsCode(25833572) and c:IsFaceup() end)
	eb:SetLabelObject(ea)
	Duel.RegisterEffect(eb,tp)
end
--Add/Special Summon Functions
function s.thfilter(c)
	return c:IsLevel(11) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
	return c:IsLevel(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.check(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetAttribute)==2
end
--Effect gain functions
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.GetAttackTarget()==e:GetHandler()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetAttacker():IsCanBeEffectTarget(e) end
	Duel.SetTargetCard(Duel.GetAttacker())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(0)
		tc:RegisterEffect(e1)
	end
end
