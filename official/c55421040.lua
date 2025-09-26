--JP name
--Hunting Horn
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon 1 EARTH Warrior Fusion Monster from your Extra Deck, using Warrior monsters from your hand or field, then if you activated this card during the Battle Phase, you can choose monsters your opponent controls, up to the number of materials used from the hand for this Fusion Summon, and their ATK become halved until the end of the Battle Phase
	local e1=Fusion.CreateSummonEff({
				handler=c,
				fusfilter=function(c) return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR) end,
				matfilter=function(c) return c:IsRace(RACE_WARRIOR) end,
				stage2=s.stage2
			})
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetHintTiming(TIMING_BATTLE_PHASE,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_BATTLE_PHASE|TIMING_BATTLE_STEP_END|TIMING_BATTLE_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_ATTACK,function(c) return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR) end)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_ATTACK)==0 end
	e:SetLabel(Duel.IsBattlePhase() and 1 or 0)
	local c=e:GetHandler()
	aux.RegisterClientHint(c,EFFECT_FLAG_OATH,tp,1,0,aux.Stringid(id,1))
	--You cannot declare attacks the turn you activate this card, except with EARTH Warrior monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return not (c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR)) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.stage2(e,fc,tp,sg,chk)
	if chk==1 and e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetLabel()==1 then
		local ct=sg:FilterCount(Card.IsPreviousLocation,nil,LOCATION_HAND)
		if ct>0 and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
			local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,ct,nil)
			if #g==0 then return end
			Duel.HintSelection(g)
			local c=e:GetHandler()
			Duel.BreakEffect()
			for sc in g:Iter() do
				--Their ATK become halved until the end of the Battle Phase
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_SET_ATTACK_FINAL)
				e1:SetValue(sc:GetAttack()//2)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
				sc:RegisterEffect(e1)
			end
		end
	end
end