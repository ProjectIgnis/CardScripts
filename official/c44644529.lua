--双天の転身
--Dual Avatar Turning
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Special summon 1 "Dual Avatar" monster from deck or extra deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	--Add 1 "Dual Avatar" monster from GY to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
	--Lists "Dual Avatar" archetype
s.listed_series={0x14e}
	--Can special summon ED monsters outside EMZ? Cache the result
s.fsx_anywhere=Duel.IsDuelType(DUEL_FSX_MMZONE)
	--Check "Dual Avatar" monster to destroy
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x14e) and c:IsLevelAbove(1)
end
	--Check "Dual Avatar" monster to special summon
function s.spfilter(c,e,tp,tc,is_emz,has_mmz)
	if (not c:IsSetCard(0x14e)) or (not c:IsLevelAbove(1)) or
	   (not (math.abs(c:GetOriginalLevel()-tc:GetLevel())==1)) or
	   (not c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)) then
		return false
	end
	if c:IsLocation(LOCATION_DECK) then
		return (not is_emz) or (is_emz and has_mmz)
	else --c:IsLocation(LOCATION_EXTRA)
		if s.fsx_anywhere then return true end
		return Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
	end
end
	--Compound filter for proper target selection
function s.tgfilter(c,e,tp)
	local is_emz=c:IsInExtraMZone(tp)
	local has_mmz=Duel.GetLocationCount(tp, LOCATION_MZONE)>0
	return s.desfilter(c) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,e,tp,c,is_emz,has_mmz)
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
end
	--Destroy targeted monster, and if you do, special summon 1 "Dual Avatar" monster from deck or extra deck
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local is_emz=tc:IsInExtraMZone(tp)
		local has_mmz=Duel.GetLocationCount(tp, LOCATION_MZONE)>0
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil,e,tp,tc,is_emz,has_mmz)
			if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
		end
	end
end
	--During your main phase, except the turn it was sent
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and Duel.IsTurnPlayer(tp) and aux.exccon(e)
end
	--Check for "Dual Avatar" monster
function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x14e) and c:IsAbleToHand()
end
	--Activation legality
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
	--Add 1 "Dual Avatar" monster from GY to hand
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
