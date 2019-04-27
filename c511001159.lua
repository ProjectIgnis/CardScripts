--Vision
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.ConfirmCards(1-tp,tc)
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetCondition(s.effcon)
		e1:SetOperation(s.effop)
		e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
		e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
		e1:SetLabel(tc:GetCode())
		e1:SetLabelObject(tc)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
		e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		Duel.RegisterEffect(e2,tp)
		local e3=e2:Clone()
		e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
		e3:SetCode(EVENT_SPSUMMON_SUCCESS)
		Duel.RegisterEffect(e3,tp)
		local e4=e2:Clone()
		e4:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
		e4:SetCondition(s.effcon2)
		e4:SetCode(EVENT_CHAIN_SOLVED)
		Duel.RegisterEffect(e4,tp)
	end
end
function s.filter(c,tc,code)
	return c==tc or c:IsCode(code)
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()~=0 and eg:IsExists(s.filter,1,nil,e:GetLabelObject(),e:GetLabel())
end
function s.effcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()~=0 and re and (re:GetHandler()==e:GetLabelObject() or re:GetHandler():IsCode(e:GetLabel()))
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,1000,REASON_EFFECT)
end
