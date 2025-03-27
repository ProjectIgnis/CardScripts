--デスルークデーモン
--Desrook Archfiend
local s,id=GetID()
function s.initial_effect(c)
	--Once per turn, during your Standby Phase, you must pay 500 LP (this is not optional), or this card is destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e1:SetOperation(s.mtop)
	c:RegisterEffect(e1)
	--Roll a six-sided die when resolving an opponent's card effect that targets this card
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--Special Summon 1 "Terrorking Archfiend" from your GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCost(Cost.SelfToGrave)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_names={35975813} --"Terrorking Archfiend"
s.roll_dice=true
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CheckLPCost(tp,500) then
		Duel.PayLPCost(tp,500)
	else
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(re) and ep==1-tp) then return end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not tg or not tg:IsContains(c) or not Duel.IsChainDisablable(ev) then return false end
	local rc=re:GetHandler()
	Duel.Hint(HINT_CARD,1-tp,id)
	local dc=Duel.TossDice(tp,1)
	if dc~=3 then return end
	if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) then
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
function s.spfilter(c,e,tp)
	return c:IsCode(35975813) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_DESTROY) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:IsExists(s.spfilter,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=eg:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end