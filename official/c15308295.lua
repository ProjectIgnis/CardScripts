--魔界劇団－コミック・リリーフ
--Abyss Actor - Comic Relief
--Scripted by ahtelel
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	--avoid damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetValue(1)
	c:RegisterEffect(e3)	
	--control
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.ctcon)
	e4:SetTarget(s.cttg2)
	e4:SetOperation(s.ctop2)
	c:RegisterEffect(e4)
	--destroy
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_CONTROL_CHANGED)
	e5:SetCountLimit(1)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end	
function s.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM) and c:IsAbleToChangeControler()
end
s.listed_series={0x10ec,0x20ec}
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil)
		and Duel.IsExistingTarget(s.ctfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g1=Duel.SelectTarget(tp,s.ctfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g2=Duel.SelectTarget(tp,Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local a=g:GetFirst()
	local b=g:GetNext()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and a:IsRelateToEffect(e) and b:IsRelateToEffect(e) and Duel.SwapControl(a,b) then
		Duel.BreakEffect()
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer()
end
function s.cttg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
function s.ctop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)>0 then
			local zone=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0)>>16
			Duel.GetControl(c,1-tp,0,0,zone)
		else
			Duel.Destroy(c,REASON_RULE)
		end
	end
end
function s.desfilter(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL) and c:IsSetCard(0x20ec)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,e:GetHandler():GetOwner(),LOCATION_SZONE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetOwner()
	local g=Duel.GetMatchingGroup(s.desfilter,p,LOCATION_SZONE,0,nil)
	if #g>0 and Duel.SelectYesNo(p,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_DESTROY)
		local sg=g:Select(p,1,1,nil)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
