--真紅眼の黒刃竜
--Red-Eyes Slash Dragon
--Scripted by Sahim
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcCodeFun(c,CARD_REDEYES_B_DRAGON,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),1,true)
	--Equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.eqcon)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	--Negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCondition(s.ngcon)
	e2:SetCost(s.ngcost)
	e2:SetTarget(s.ngtg)
	e2:SetOperation(s.ngop)
	c:RegisterEffect(e2)
	--special summon
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetOperation(s.eqcheck)
	c:RegisterEffect(e4)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	e3:SetLabelObject(e4)
	c:RegisterEffect(e3)
end
s.listed_series={0x3b}
s.listed_names={CARD_NECROVALLEY}
s.material_setcode=0x3b
function s.eqcon(e)
	return Duel.GetAttacker():IsSetCard(0x3b)
end
function s.eqfilter(c,tp)
	return c:IsRace(RACE_WARRIOR) and c:CheckUniqueOnField(tp) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.eqfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Equip(tp,tc,c,true) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(c)
		tc:RegisterEffect(e1)
		--atkup
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(200)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.ngcfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField()
end
function s.ngcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(s.ngcfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
function s.ngfilter(c,e,tp)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToGraveAsCost()
end
function s.ngcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ngfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.ngfilter,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.ngop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function s.eqcheck(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject() then e:GetLabelObject():DeleteGroup() end
	local g=e:GetHandler():GetEquipGroup()
	g:KeepAlive()
	e:SetLabelObject(g)
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_EFFECT+REASON_BATTLE)~=0
end
function s.spfilter2(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():GetLabelObject()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:IsExists(s.spfilter2,1,nil,e,tp) and not Duel.IsEnvironment(CARD_NECROVALLEY) end
	local sg=g:Filter(s.spfilter2,nil,e,tp)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,#sg,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetTargetCards(e)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if #sg>ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		sg=sg:Select(tp,ft,ft,nil)
	end
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
