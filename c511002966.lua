--Amazoness Secret Hot Spring
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--confirm
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetDescription(aux.Stringid(90519313,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.rectg)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
	--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetCondition(s.descon)
	c:RegisterEffect(e4)
	aux.GlobalCheck(s,function()
		s[0]={}
		s[1]={}
		s[2]=0
		s[3]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DAMAGE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetCountLimit(1)
		ge2:SetOperation(s.clear)
		Duel.RegisterEffect(ge2,0)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then
		s[tp+2]=s[tp+2]+1
		s[tp][s[tp+2]]=ev
	end
	if ep==1-tp then
		s[1-tp+2]=s[1-tp+2]+1
		s[1-tp][s[1-tp+2]]=ev
	end
end
function s.clear(e,tp,eg,ep,ev,re,r,rp)
	s[0]={}
	s[1]={}
	s[2]=0
	s[3]=0
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x4)
end
function s.descon(e)
	return not Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s[2+tp]>0 end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local t=s[tp]
	local lp=Duel.AnnounceNumber(tp,table.unpack(t))
	Duel.Recover(tp,lp,REASON_EFFECT)
end
