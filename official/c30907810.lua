--魔弾の悪魔 ザミエル
--Magical Musket Mastermind Zakiel
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	-- summon with 1 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),s.otfilter)
	--activate from hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x108))
	e2:SetTargetRange(LOCATION_HAND,0)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e3)
	--draw
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.drcon)
	e4:SetTarget(s.drtg)
	e4:SetOperation(s.drop)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetLabelObject(e4)
	e5:SetOperation(s.regop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_CHAIN_NEGATED)
	e6:SetOperation(s.regop2)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e7:SetOperation(s.clearop)
	c:RegisterEffect(e7)
	local e8=e6:Clone()
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_LEAVE_FIELD_P)
	e8:SetOperation(s.clearop)
	c:RegisterEffect(e8)
end
s.listed_series={0x108}
function s.otfilter(c,tp)
	return c:IsSetCard(0x108) and (c:IsControler(tp) or c:IsFaceup())
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsSetCard(0x108) and rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local val=e:GetLabelObject():GetLabel()
		e:GetLabelObject():SetLabel(val+1)
	end
end
function s.regop2(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsSetCard(0x108) and rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local val=e:GetLabelObject():GetLabel()
		if val==0 then val=1 end
		e:GetLabelObject():SetLabel(val-1)
	end
end
function s.clearop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=e:GetLabel()
	if chk==0 then return d>0 and Duel.IsPlayerCanDraw(tp,d) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,d)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local d=e:GetLabel()
	if d>0 then
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
