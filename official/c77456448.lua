--魔法効果の剣
--Spell Shattering Sword
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects;
	--● Destroy all face-up Spells your opponent controls
	--● Target 1 face-up monster your opponent controls; show 1 "Light and Darkness Ritual" from your hand or GY, then change that monster's ATK to 0, also negate its effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E|TIMING_DAMAGE_STEP)
	c:RegisterEffect(e1)
	--If this card in its owner's possession is destroyed by an opponent's card: You can destroy 1 card in your opponent's hand (at random) or field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
	end)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_HAND|LOCATION_ONFIELD,1,nil) end
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_HAND|LOCATION_ONFIELD)
	end)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local hand_group=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
		local field_group=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
		local option_1=#hand_group>0
		local option_2=#field_group>0
		if not (option_1 or option_2) then return end
		local choice=(option_1 and option_2
			and Duel.SelectEffect(tp,
				{option_1,aux.Stringid(id,4)},
				{option_2,aux.Stringid(id,5)}))
			or (option_1 and 1) or (option_2 and 2)
		local desg=Group.CreateGroup()
		if choice==1 then
			desg=hand_group:RandomSelect(tp,1)
		elseif choice==2 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			desg=field_group:Select(tp,1,1,nil)
			Duel.HintSelection(desg)
		end
		if #desg>0 then
			Duel.Destroy(desg,REASON_EFFECT)
		end
	end)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_LIGHT_AND_DARKNESS_RITUAL}
function s.disfilter(c)
	return (not c:IsAttack(0) or c:IsNegatableMonster()) and c:IsFaceup()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	--● Destroy all face-up Spells your opponent controls
	local opp_spells=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSpell),tp,0,LOCATION_ONFIELD,nil)
	local option_1=#opp_spells>0 and not Duel.IsDamageStep()
	--● Target 1 face-up monster your opponent controls; show 1 "Light and Darkness Ritual" from your hand or GY, then change that monster's ATK to 0, also negate its effects
	local option_2=Duel.IsExistingTarget(s.disfilter,tp,0,LOCATION_MZONE,1,nil) and aux.StatChangeDamageStepCondition()
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,CARD_LIGHT_AND_DARKNESS_RITUAL)
	if chk==0 then return option_1 or option_2 end
	local cd=e:GetChainData()
	cd.choice=Duel.SelectEffect(tp,
		{option_1,aux.Stringid(id,2)},
		{option_2,aux.Stringid(id,3)})
	if cd.choice==1 then
		--● Destroy all face-up Spells your opponent controls
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,opp_spells,#opp_spells,tp,0)
	elseif cd.choice==2 then
		--● Target 1 face-up monster your opponent controls; show 1 "Light and Darkness Ritual" from your hand or GY, then change that monster's ATK to 0, also negate its effects
		e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local g=Duel.SelectTarget(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local cd=e:GetChainData()
	if cd.choice==1 then
		--● Destroy all face-up Spells your opponent controls
		local opp_spells=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSpell),tp,0,LOCATION_ONFIELD,nil)
		if #opp_spells>0 then
			Duel.Destroy(opp_spells,REASON_EFFECT)
		end
	elseif cd.choice==2 then
		--● Target 1 face-up monster your opponent controls; show 1 "Light and Darkness Ritual" from your hand or GY, then change that monster's ATK to 0, also negate its effects
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local sc=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,CARD_LIGHT_AND_DARKNESS_RITUAL):GetFirst()
		if not sc then return end
		if sc:IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,sc)
			Duel.ShuffleHand(tp)
		else
			Duel.HintSelection(sc)
		end
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local c=e:GetHandler()
			Duel.BreakEffect()
			--Change that monster's ATK to 0
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
			--Also negate its effects
			tc:NegateEffects(c)
		end
	end
end
