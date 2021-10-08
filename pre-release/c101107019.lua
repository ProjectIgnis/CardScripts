-- 変異体ミュートリア
-- Myutant Mutator
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon self
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	-- Special Summon from hand or Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={0x159}
s.listed_names={34695290,61089209,7574904}
function s.hspcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x159),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.smnfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.typetocode(type)
	if type&TYPE_MONSTER==TYPE_MONSTER then return 34695290 end -- Myutant Beast
	if type&TYPE_SPELL==TYPE_SPELL then return 61089209 end -- Myutant Mist
	if type&TYPE_TRAP==TYPE_TRAP then return 7574904 end -- Myutant Arsenal
	return -1
end
function s.spcostfilter(c,e,tp)
	return c:IsSetCard(0x159) and c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.smnfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,c,e,tp,s.typetocode(c:GetOriginalType()))
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c,e,tp) end
	Duel.Release(c,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,c,e,tp)
	e:SetLabelObject(rg:GetFirst())
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetLabelObject()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 or not rc then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.smnfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp,s.typetocode(rc:GetOriginalType()))
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local atk=g:GetFirst():GetBaseAttack()
		if atk>0 then Duel.SetLP(tp,Duel.GetLP(tp)-atk) end
	end
end