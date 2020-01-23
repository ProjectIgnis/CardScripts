--クラッキング
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local d1=false
	local d2=false
	local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
		if tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsType(TYPE_MONSTER) and tc:IsReason(REASON_EFFECT) then
			if tc:GetControler()==0 then d1=true
			else d2=true end
		end
	end
	local evt_p=PLAYER_NONE
	if d1 and d2 then evt_p=PLAYER_ALL
	elseif d1 then evt_p=0
	elseif d2 then evt_p=1 end
	e:SetLabel(evt_p)
	return evt_p~=PLAYER_NONE
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,e:GetLabel(),0)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	Duel.SetTargetParam(800)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,ep,800)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if ep==PLAYER_ALL then
		Duel.Damage(tp,d,REASON_EFFECT,true)
		Duel.Damage(1-tp,d,REASON_EFFECT,true)
		Duel.RDComplete()
	else
		Duel.Damage(ep,d,REASON_EFFECT)
	end
end
