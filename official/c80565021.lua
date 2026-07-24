--JP name
--Angelechy Opening to e4
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--If your opponent goes first, you can also activate this card from your hand during the Standby Phase of their first turn
	local e4a=Effect.CreateEffect(c)
	e4a:SetType(EFFECT_TYPE_SINGLE)
	e4a:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e4a:SetCondition(function(e)
		return Duel.GetTurnCount()==1 and Duel.IsStandbyPhase(1-e:GetHandlerPlayer())
	end)
	c:RegisterEffect(e4a)
	--Place 1 "Angelechy" Field Spell from your hand, Deck, or GY, face-up on your field, and if you do, Special Summon 1 Level 2 or 7 "Angelechy" monster from your Extra Deck to the Extra Monster Zone, and if you do that, place 1 "Angelechy" monster from your Extra Deck in your Spell & Trap Zone as a face-up Continuous Spell. Until the end of your next turn after this card resolves, you cannot Special Summon from the Extra Deck, except Synchro Monsters
	local e4b=Effect.CreateEffect(c)
	e4b:SetDescription(aux.Stringid(id,0))
	e4b:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4b:SetType(EFFECT_TYPE_ACTIVATE)
	e4b:SetCode(EVENT_FREE_CHAIN)
	e4b:SetTarget(s.pltg)
	e4b:SetOperation(s.plop)
	e4b:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e4b)
end
s.listed_series={SET_ANGELECHY}
function s.plfilter(c,field)
	return c:IsSetCard(SET_ANGELECHY) and not c:IsForbidden() and (not field or c:IsFieldSpell())
end
function s.spfilter(c,e,tp)
	return c:IsLevel(2,7) and c:IsSetCard(SET_ANGELECHY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c,ZONES_EMZ)>0 and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_EXTRA,0,1,c)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local stzone_count=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then stzone_count=stzone_count-1 end
		return stzone_count>0 and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,true)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.plfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,true):GetFirst()
	if tc then
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
		end
		if Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
			if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,ZONES_EMZ)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
				local sc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
				if sc and Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
					--Treated as a Continuous Spell
					local e4=Effect.CreateEffect(c)
					e4:SetType(EFFECT_TYPE_SINGLE)
					e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e4:SetCode(EFFECT_CHANGE_TYPE)
					e4:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
					e4:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
					sc:RegisterEffect(e4)
				end
			end
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	local reset_count=Duel.IsTurnPlayer(tp) and 2 or 1
	--Until the end of your next turn after this card resolves, you cannot Special Summon from the Extra Deck, except Synchro Monsters
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetTargetRange(1,0)
	e4:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsSynchroMonster() end)
	e4:SetReset(RESET_PHASE|PHASE_END|RESET_SELF_TURN,reset_count)
	Duel.RegisterEffect(e4,tp)
end