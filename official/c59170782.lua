--水精鱗－アビストリーテ
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,3,3)
	c:EnableReviveLimit()
	--change target
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.tgcon1)
	e1:SetCost(s.tgcost)
	e1:SetOperation(s.tgop1)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.tgcon2)
	e2:SetCost(s.tgcost)
	e2:SetOperation(s.tgop2)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={0x74}
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.tgcon1(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsActiveType(TYPE_SPELL+TYPE_TRAP) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or #g~=1 then return false end
	local tc=g:GetFirst()
	local c=e:GetHandler()
	if tc==c or tc:GetControler()~=tp or tc:IsFacedown() or not tc:IsLocation(LOCATION_MZONE) or not tc:IsSetCard(0x74) then return false end
	local tf=re:GetTarget()
	local res,ceg,cep,cev,cre,cr,crp=Duel.CheckEvent(re:GetCode(),true)
	return tf(re,rp,ceg,cep,cev,cre,cr,crp,0,c)
end
function s.tgop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local tf=re:GetTarget()
		local res,ceg,cep,cev,cre,cr,crp=Duel.CheckEvent(re:GetCode(),true)
		if tf(re,rp,ceg,cep,cev,cre,cr,crp,0,c) then
			local g=Group.CreateGroup()
			g:AddCard(c)
			Duel.ChangeTargetCard(ev,g)
		end
	end
end
function s.tgcon2(e,tp,eg,ep,ev,re,r,rp)
	if tp==Duel.GetTurnPlayer() then return false end
	local at=Duel.GetAttackTarget()
	if at and at:IsFaceup() and at:IsSetCard(0x74) then
		local ag=eg:GetFirst():GetAttackableTarget()
		return ag:IsContains(e:GetHandler())
	end
	return false
end
function s.tgop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and not Duel.GetAttacker():IsImmuneToEffect(e) then
		Duel.ChangeAttackTarget(c)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x74) and c:GetCode()~=id and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
