--ゴーストリック・アート
--Ghostrick Art
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Tribute up to 2 "Ghostrick" monsters from your hand and/or field, and if you do, Special Summon that many "Ghostrick" monsters from your Deck with different names from each other, each in face-up or face-down Defense Position, also you cannot Special Summon for the rest of this turn, except DARK monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(TIMING_END_PHASE,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--During your Main Phase: You can banish this card from your GY; change 1 face-down Defense Position "Ghostrick" monster you control to face-up Defense Position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GHOSTRICK}
function s.tributefilter(c,tp)
	return c:IsSetCard(SET_GHOSTRICK) and c:IsReleasableByEffect() and Duel.GetMZoneCount(tp,c)>0
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_GHOSTRICK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE|POS_FACEDOWN_DEFENSE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.tributefilter,1,true,1,false,nil,tp,nil,false,nil,tp)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tribute_group=Duel.GetReleaseGroup(tp,true,false,REASON_EFFECT):Match(s.tributefilter,nil,tp)
	local max_sp_count=Duel.GetMZoneCount(tp,tribute_group)
	local summon_group=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	max_sp_count=math.min(2,max_sp_count,summon_group:GetClassCount(Card.GetCode))
	if max_sp_count>0 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then max_sp_count=1 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g=tribute_group:Select(tp,1,max_sp_count,nil)
		local tribute_count=Duel.Release(g,REASON_EFFECT)
		if tribute_count>0 then
			local sg=aux.SelectUnselectGroup(summon_group,e,tp,tribute_count,tribute_count,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
			if #sg==tribute_count and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE|POS_FACEDOWN_DEFENSE)==#sg
				and #sg:Match(Card.IsFacedown,nil)>0 then
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	end
	--You cannot Special Summon for the rest of this turn, except DARK monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c)
		return c:IsAttributeExcept(ATTRIBUTE_DARK)
	end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.posfilter(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and c:IsSetCard(SET_GHOSTRICK) and c:IsCanChangePosition()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,LOCATION_MZONE)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
end