--百鬼羅刹大収監
--Goblin Biker Grand Breakout
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Goblin" monster from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--All face-up monsters your opponent currently controls lose 1000 ATK for each material detached
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.atkcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GOBLIN}
function s.spcostfilter(c,tp)
	return Duel.GetMZoneCount(tp,c)>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.spcostfilter,1,false,nil,nil,tp) end
	local sg=Duel.SelectReleaseGroupCost(tp,s.spcostfilter,1,1,false,nil,nil,tp)
	Duel.Release(sg,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_GOBLIN) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local cost_chk=e:GetLabel()==1
		e:SetLabel(0)
		return (cost_chk or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		--Cannot attack this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3206)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
function s.atkcostfilter(c)
	return c:IsSetCard(SET_GOBLIN) and c:IsType(TYPE_XYZ) and c:IsFaceup() and c:GetOverlayCount()>0
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-1)
	local c=e:GetHandler()
	local xyzg=Duel.GetMatchingGroup(s.atkcostfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return c:IsAbleToRemoveAsCost() and #xyzg>0 and Duel.CheckRemoveOverlayCard(tp,0,0,1,REASON_COST,xyzg) end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	local maxct=xyzg:GetSum(Card.GetOverlayCount)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local ct=Duel.RemoveOverlayCard(tp,0,0,1,maxct,REASON_COST,xyzg)
	e:SetLabel(ct)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local atkg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if chk==0 then
		local cost_chk=e:GetLabel()==-1
		e:SetLabel(0)
		return cost_chk and #atkg>0
	end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,atkg,#atkg,tp,e:GetLabel()*-1000)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end
	local c=e:GetHandler()
	local atk=e:GetLabel()*-1000
	for tc in g:Iter() do
		--It loses 1000 ATK for each material detached
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end