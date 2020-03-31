--ライトロード・プリースト ジェニス
local s,id=GetID()
function s.initial_effect(c)
	--recover&damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.lpcon)
	e1:SetTarget(s.lptg)
	e1:SetOperation(s.lpop)
	c:RegisterEffect(e1)
	if s.discard==nil then
		s.discard=true
		s[0]=false
		s[1]=false
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		e2:SetOperation(s.reset)
		Duel.RegisterEffect(e2,0)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e3:SetCode(EVENT_TO_GRAVE)
		e3:SetOperation(s.set)
		Duel.RegisterEffect(e3,0)
	end
end
s.listed_series={0x38}
function s.reset(e,tp,eg,ep,ev,re,r,rp)
	s[0]=false
	s[1]=false
end
function s.cfilter(c)
	return c:GetPreviousLocation()==LOCATION_DECK
end
function s.set(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	if (r&REASON_EFFECT)>0 and rc:IsSetCard(0x38) and eg:IsExists(s.cfilter,1,nil) then
		s[rp]=true
	end
end
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer() and s[tp]
end
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetControler()~=tp or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	Duel.Recover(tp,500,REASON_EFFECT)
	Duel.Damage(1-tp,500,REASON_EFFECT)
end
