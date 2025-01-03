--誓いのエンブレーマ
--Emblema Oath
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_CENTURION}
function s.plfilter(c)
	return c:IsSetCard(SET_CENTURION) and c:IsMonster() and not c:IsForbidden()
end
function s.setfilter(c,ft)
	return c:IsSetCard(SET_CENTURION) and c:IsSpellTrap() and c:IsSSetable() and (ft>0 or c:IsFieldSpell())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then ft=ft-1 end
	local b1=ft>0 and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,ft)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if op==1 then
		--Place 1 "Centurion" monster from your Deck to your Spell & Trap Zone as a Continuous Trap
		if ft<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if sc and Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			sc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
			local c=e:GetHandler()
			--Treat it as a Continuous Trap
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetValue(TYPE_TRAP|TYPE_CONTINUOUS)
			e1:SetReset((RESET_EVENT|RESETS_STANDARD)&~RESET_TURN_SET)
			sc:RegisterEffect(e1)
			--Cannot Special Summon from the Extra Deck, except "Centurion" monsters
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(aux.Stringid(id,3))
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e2:SetTargetRange(1,0)
			e2:SetCondition(function() return Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_ONFIELD,0,1,nil,sc:GetOriginalCodeRule()) end)
			e2:SetTarget(function(_e,_c) return not _c:IsSetCard(SET_CENTURION) and _c:IsLocation(LOCATION_EXTRA) end)
			e2:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e2,tp)
			--Clock Lizard check
			aux.addTempLizardCheck(c,tp,function(_e,_c) return not _c:IsOriginalSetCard(SET_CENTURION) end)
		end
	elseif op==2 then
		--Set 1 "Centurion" Spell/Trap directly from your Deck
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,ft)
		if #g>0 then
			Duel.SSet(tp,g)
		end
	end
end
function s.spconfilter(c,code)
	return c:IsFaceup() and (c:HasFlagEffect(id) or c:IsOriginalCodeRule(code))
end