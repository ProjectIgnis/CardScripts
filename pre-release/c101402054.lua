--眠れる羊 スケープ・ゴート
--Sleeping Scapegoats
--scripted by pyrQ
local s,id=GetID()
local TOKEN_SCAPEGOAT=id+100
function s.initial_effect(c)
	--Special Summon up to 4 "Scapegoat Tokens" (Beast/EARTH/Level 1/ATK 0/DEF 0) in Defense Position, then if your opponent controls a monster, you can Special Summon 1 "Swift Panther Warrior" from your Deck, also for the rest of this turn, these Tokens cannot be Tributed for a Tribute Summon, also you cannot Special Summon from the Extra Deck, except Fusion Monsters. If a card(s) you control that mentions "Dark Time Wizard" would be destroyed by battle or card effect, you can destroy 1 Token you control that was Special Summoned by this effect instead
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_names={TOKEN_SCAPEGOAT,101402001,CARD_DARK_TIME_WIZARD} --"Swift Panther Warrior"
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_SCAPEGOAT,0,TYPES_TOKEN,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spfilter(c,e,tp)
	return c:IsCode(101402001) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local mmz_count=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if mmz_count>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_SCAPEGOAT,0,TYPES_TOKEN,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) then
		mmz_count=math.min(mmz_count,4)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then mmz_count=1 end
		if mmz_count>1 then
			mmz_count=Duel.AnnounceNumberRange(tp,1,mmz_count)
		end
	end
	local c=e:GetHandler()
	for i=1,mmz_count do
		local token=Duel.CreateToken(tp,TOKEN_SCAPEGOAT)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			--For the rest of this turn, these Tokens cannot be Tributed for a Tribute Summon
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3304)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetValue(1)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			token:RegisterEffect(e1,true)
		end
	end
	if Duel.SpecialSummonComplete()>0 then
		--If a card(s) you control that mentions "Dark Time Wizard" would be destroyed by battle or card effect, you can destroy 1 Token you control that was Special Summoned by this effect instead
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EFFECT_DESTROY_REPLACE)
		e2:SetTarget(s.reptg)
		e2:SetOperation(s.repop)
		e2:SetValue(function(e,c) return s.repfilter(c,e:GetHandlerPlayer()) end)
		Duel.RegisterEffect(e2,tp)
		if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.BreakEffect()
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
	--You cannot Special Summon from the Extra Deck, except Fusion Monsters
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetTargetRange(1,0)
	e3:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsFusionMonster() end)
	e3:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e3,tp)
end
function s.repfilter(c,tp)
	return c:ListsCode(CARD_DARK_TIME_WIZARD) and c:IsOnField() and c:IsControler(tp) and c:IsFaceup()
		and c:IsReason(REASON_BATTLE|REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.desfilter(c,e,tp)
	return c:IsOriginalCode(TOKEN_SCAPEGOAT) and c:IsOwner(tp) and c:IsDestructable(e)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED|STATUS_BATTLE_DESTROYED)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local sc=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
		Duel.HintSelection(sc)
		e:SetLabelObject(sc)
		sc:SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	end
	return false
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local sc=e:GetLabelObject()
	sc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(sc,REASON_EFFECT|REASON_REPLACE)
end