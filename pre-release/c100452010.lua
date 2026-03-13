--超銀河眼の光子龍－フォトン・ハウリング
--Neo Galaxy-Eyes Photon Dragon - Photon Howling
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 8 monsters OR 1 Rank 8 Xyz Monster
	Xyz.AddProcedure(c,nil,8,3,s.altmatfilter,aux.Stringid(id,0),3,s.xyzop)
	--Take 1 "Photon" monster from your Deck, and either Special Summon it in Defense Position or attach it to this card as material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() end)
	e1:SetTarget(s.spattachtg)
	e1:SetOperation(s.spattachop)
	c:RegisterEffect(e1)
	--Tribute 1 other Xyz Monster, and if you do, negate the effects of all other face-up cards currently on the field until the end of this turn.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(Cost.DetachFromSelf(3))
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e2)
end
s.listed_series={SET_PHOTON}
function s.altmatfilter(c,tp,xyzc)
	return c:IsType(TYPE_XYZ,xyzc,SUMMON_TYPE_XYZ,tp) and c:IsRank(8) and c:IsFaceup()
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
	return true
end
function s.spcheck(c,e,tp,mmz_chk)
	return mmz_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.attachcheck(c,e,tp)
	return c:IsCanBeXyzMaterial(e:GetHandler(),tp,REASON_EFFECT)
end
function s.spattachfilter(c,e,tp,mmz_chk)
	return c:IsSetCard(SET_PHOTON) and c:IsMonster() and (s.spcheck(c,e,tp,mmz_chk) or s.attachcheck(c,e,tp))
end
function s.spattachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return Duel.IsExistingMatchingCard(s.spattachfilter,tp,LOCATION_DECK,0,1,nil,e,tp,mmz_chk) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spattachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local sc=Duel.SelectMatchingCard(tp,s.spattachfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,mmz_chk):GetFirst()
	if not sc then return end
	local b1=s.spcheck(sc,e,tp,mmz_chk)
	local b2=s.attachcheck(sc,e,tp) and c:IsRelateToEffect(e)
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,4)}, --"Special Summon it in Defense Position"
		{b2,aux.Stringid(id,5)}) --"Attach it to this card as material"
	if op==1 then
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	elseif op==2 then
		Duel.Overlay(c,sc,true)
	end
end
function s.xyzfilter(c,self_exc)
	return c:IsXyzMonster() and c:IsReleasableByEffect()
		and Duel.IsExistingMatchingCard(Card.IsNegatable,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,Group.FromCards(c,self_exc))
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,c,c) end
	local g=Duel.GetMatchingGroup(Card.IsNegatable,0,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g-1,tp,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local exc=c:IsRelateToEffect(e) and c or nil
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,exc,exc)
	if not sc then return end
	Duel.HintSelection(sc)
	if Duel.Release(sc,REASON_EFFECT)>0 then
		local g=Duel.GetMatchingGroup(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,exc)
		--Negate the effects of all other face-up cards currently on the field until the end of this turn
		for tc in g:Iter() do
			tc:NegateEffects(c,RESET_PHASE|PHASE_END)
		end
	end
end