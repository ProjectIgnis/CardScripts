--Gladiator Beast Fort
local s,id=GetID()
function s.initial_effect(c)
	c:RegisterFlagEffect(511002973,0,0,0)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--attach
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19310321,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.gbcon)
	e2:SetTarget(s.gbtg)
	e2:SetOperation(s.gbop)
	c:RegisterEffect(e2)
	--damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(17415895,0))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(s.damcost)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	--target
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(82962242,0))
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
	--battle
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_QUICK_F)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e5:SetCondition(s.btcon)
	e5:SetTarget(s.bttg)
	e5:SetOperation(s.btop)
	c:RegisterEffect(e5)
	--effect
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_QUICK_F)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCode(EVENT_BECOME_TARGET)
	e6:SetTarget(s.efftg)
	e6:SetOperation(s.effop)
	c:RegisterEffect(e6)
end
function s.gbcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()==0
end
function s.gbfilter(c)
	return c:IsSetCard(0x19) and c:IsType(TYPE_MONSTER)
end
function s.gbtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.gbfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.gbop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.SelectMatchingCard(tp,s.gbfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Overlay(c,g)
	end
end
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetHandler():GetOverlayGroup()
	if chk==0 then return g:IsExists(Card.IsAbleToDeckAsCost,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:FilterSelect(tp,Card.IsAbleToDeckAsCost,1,1,nil)
	Duel.SendtoDeck(sg,nil,2,REASON_COST)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x19) and c:GetFlagEffect(id)==0 and c:GetFlagEffect(id+1)==0 
		and c:GetFlagEffect(511002972)==0 and c:GetFlagEffect(511002973)==0
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	local op=0
	if tc then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(76922029,0))
		if tc:GetFlagEffect(id)==0 and tc:GetFlagEffect(id+1)==0 then
			op=Duel.SelectOption(tp,aux.Stringid(77700347,0),aux.Stringid(50789693,1))
		elseif tc:GetFlagEffect(id)==0 then
			Duel.SelectOption(tp,aux.Stringid(77700347,0))
			op=0
		else
			Duel.SelectOption(tp,aux.Stringid(50789693,1))
			op=1
		end
		if op==0 then
			tc:RegisterFlagEffect(511002972,RESET_CHAIN,0,0)
		else
			tc:RegisterFlagEffect(511002973,RESET_CHAIN,0,0)
		end
	end
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if tc:GetFlagEffect(511002972)>0 then
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
		elseif tc:GetFlagEffect(511002973)>0 then
			tc:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD,0,0)
		end
	end
end
function s.btcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return d and (a:GetFlagEffect(id)>0 or d:GetFlagEffect(id)>0)
end
function s.bttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local g=Group.CreateGroup()
	if a:GetFlagEffect(id)>0 then g:AddCard(a) end
	if d:GetFlagEffect(id)>0 then g:AddCard(d) end
	Duel.SetTargetCard(g)
end
function s.btop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	if c:IsRelateToEffect(e) then
		local tc=g:GetFirst()
		while tc do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
			e2:SetValue(1)
			e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
			tc:RegisterEffect(e2)
			tc=g:GetNext()
		end
	end
end
function s.cfilter(c)
	return c:GetFlagEffect(id+1)>0
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.cfilter,1,nil) end
	local g=eg:Filter(s.cfilter,nil)
	Duel.SetTargetCard(g)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	if c:IsRelateToEffect(e) then
		local tc=g:GetFirst()
		while tc do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e1:SetValue(s.indesval)
			e1:SetReset(RESET_CHAIN)
			e1:SetLabelObject(re)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
	end
end
function s.indesval(e,re)
	return re==e:GetLabelObject()
end
