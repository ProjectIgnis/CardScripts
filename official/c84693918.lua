--ドレミコード・ソルフェージア
--Solfachord Solfegia
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--Negate a monster effect activated by your opponent, then destroy this card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.discon)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--Special Summon this card from your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp) return not Duel.IsExistingMatchingCard(aux.NOT(aux.FaceupFilter(Card.IsSetCard,SET_SOLFACHORD)),tp,LOCATION_MZONE,0,1,nil) end)
	e2:SetTarget(s.selfsptg)
	e2:SetOperation(s.selfspop)
	c:RegisterEffect(e2)
	--Special Summon 1 "Solfachord" monster from your hand, except "Solfachord Solfeggia"
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_names={id}
s.listed_series={SET_GRANSOLFACHORD,SET_SOLFACHORD}
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect() and Duel.IsChainDisablable(ev) and not Duel.HasFlagEffect(tp,id)
		and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_GRANSOLFACHORD),tp,LOCATION_MZONE,0,1,nil)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,2)) then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	Duel.Hint(HINT_CARD,0,id)
	if Duel.NegateEffect(ev) then
		Duel.BreakEffect()
		Duel.Destroy(c,REASON_EFFECT)
	end
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.spfilter(c,e,tp,exc)
	if not (c:IsSetCard(SET_SOLFACHORD) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_HAND|LOCATION_GRAVE) then
		return Duel.GetMZoneCount(tp,exc)>0
	elseif c:IsLocation(LOCATION_EXTRA) then
		return c:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,exc,c)>0
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cost_chk=Cost.SelfTribute(e,tp,eg,ep,ev,re,r,rp,0)
	local exc=cost_chk and e:GetHandler() or nil
	local location=cost_chk and LOCATION_HAND|LOCATION_GRAVE|LOCATION_EXTRA or LOCATION_HAND
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,location,0,1,nil,e,tp,exc) end
	local hand_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	if cost_chk and (not hand_chk or Duel.SelectYesNo(tp,aux.Stringid(id,3))) then
		Cost.SelfTribute(e,tp,eg,ep,ev,re,r,rp,1)
		e:SetLabel(LOCATION_HAND|LOCATION_GRAVE|LOCATION_EXTRA)
	else 
		e:SetLabel(LOCATION_HAND)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,e:GetLabel())
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,e:GetLabel(),0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end