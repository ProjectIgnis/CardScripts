--終焉龍 カオス・エンペラー
--Chaos Emperor, the Dragon of Armageddon
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c)
	--Add 1 banished Dragon monster to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.PayLP(1000))
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Special Summon condition
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	--Special Summon procedure
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
	e3:SetRange(LOCATION_EXTRA|LOCATION_HAND)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--Send cards to the GY and inflict damage
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(s.gycost)
	e4:SetTarget(s.gytg)
	e4:SetOperation(s.gyop)
	c:RegisterEffect(e4)
	--Send itself to the Deck if it leaves the field
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e5:SetValue(LOCATION_DECKBOT)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetOperation(function(e) e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1) end)
	c:RegisterEffect(e6)
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(s.atchk1,1,nil,sg)
		and ((not e:GetHandler():IsLocation(LOCATION_EXTRA) and aux.ChkfMMZ(1)(sg,e,tp,mg))
		or (e:GetHandler():IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,sg,e:GetHandler())>0))
end
function s.atchk1(c,sg)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and sg:FilterCount(Card.IsAttribute,c,ATTRIBUTE_DARK)==1
end
function s.spfilter(c,att)
	return c:IsAttribute(att) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil,ATTRIBUTE_LIGHT)
	local rg2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil,ATTRIBUTE_DARK)
	local rg=rg1:Clone()
	rg:Merge(rg2)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and #rg1>0 and #rg2>0
		and aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil,ATTRIBUTE_LIGHT|ATTRIBUTE_DARK)
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else
		return false
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	g:DeleteGroup()
end
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function s.sgfilter(c,p)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(p)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_SZONE|LOCATION_MMZONE,0,nil)
	local og=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return #g>0 and #og>0 end
	local oc=#og
	g:Merge(og)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,oc*300)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_SZONE|LOCATION_MMZONE,0,nil)
	if #g==0 or Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
	local oc=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
	if oc==0 then return end
	local dc=Duel.GetOperatedGroup():FilterCount(s.sgfilter,nil,1-tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local og=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,oc,nil)
	if Duel.SendtoGrave(og,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		dc=dc+Duel.GetOperatedGroup():FilterCount(s.sgfilter,nil,1-tp)
		Duel.Damage(1-tp,dc*300,REASON_EFFECT)
	end
end