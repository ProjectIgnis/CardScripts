--究極宝玉神 レインボー・ドラゴン オーバー・ドライブ
--Ultimate Crystal Rainbow Dragon Overdrive
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--1 "Ultimate Crystal" Monster + 7 "Crystal Beast" Monsters
	Fusion.AddProcMixRep(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_CRYSTAL_BEAST),7,7,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_ULTIMATE_CRYSTAL))
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.contactlim,s.contactcon)
	--Register "Ultimate Crystal" Special Summon
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end)
	--Cannot be Special Summoned by other ways
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	--Gains 700 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.atkcon)
	e1:SetValue(7000)
	c:RegisterEffect(e1)
	--Shuffle as many cards into the Deck as possible and Special Summon "Crystal Beast" monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e2:SetCondition(function(e) return e:GetHandler():GetBattledGroupCount()==0 end)
	e2:SetCost(Cost.SelfTribute)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ULTIMATE_CRYSTAL,SET_CRYSTAL_BEAST}
s.material_setcode={SET_ULTIMATE_CRYSTAL,SET_CRYSTAL_BEAST}
function s.contactfil(tp)
	local loc=Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) and LOCATION_MZONE or LOCATION_MZONE|LOCATION_GRAVE
	return Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,loc,0,nil)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_MATERIAL)
end
function s.contactlim(e)
	return e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function s.contactcon(tp)
	return Duel.GetFlagEffect(tp,id)>0
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	for ec in eg:Iter() do
		if ec:IsSetCard(SET_ULTIMATE_CRYSTAL) and ec:IsFaceup() then
			Duel.RegisterFlagEffect(ec:GetSummonPlayer(),id,0,0,0)
		end
	end
end
function s.cbfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_CRYSTAL_BEAST)
end
function s.atkcon(e)
	return Duel.GetMatchingGroup(s.cbfilter,e:GetHandlerPlayer(),LOCATION_REMOVED,0,nil):GetClassCount(Card.GetCode)>=7
end
function s.spfilter(c,e,tp)
	return s.cbfilter(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	if chk==0 then return #g>0 and Duel.GetMZoneCount(tp,g+c)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g<=0 or Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)<=0 then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,ft,nil,e,tp)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end