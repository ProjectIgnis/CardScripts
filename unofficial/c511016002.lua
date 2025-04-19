--アルカナフォース０－THE FOOL (Anime)
--Arcana Force 0 - The Fool (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--battle indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e2:SetCondition(s.poscon)
	c:RegisterEffect(e2)
	--coin
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(62892347,0))
	e3:SetCategory(CATEGORY_COIN)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetTarget(s.cointg)
	e3:SetOperation(s.coinop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e5)
	--coin selection
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(id)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(0,1)
	c:RegisterEffect(e6)
	--function overwrite scripted by MLD
	local f=Duel.TossCoin
	Duel.TossCoin=function(tp,ct)
		if Duel.IsPlayerAffectedByEffect(tp,id) and Duel.SelectYesNo(tp,1623) then
			local tct=ct
			local t={}
			for i=1,ct do
				table.insert(t,Duel.AnnounceCoin(tp))
			end
			return table.unpack(t)
		else
			return f(tp,ct)
		end
	end
end
s.toss_coin=true
function s.poscon(e)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	s.arcanareg(c,Arcana.TossCoin(c,tp))
end
function s.arcanareg(c,coin)
	--cannot be target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.tgval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(s.unval)
	c:RegisterEffect(e2)
	Arcana.RegisterCoinResult(c,coin)
end
function s.tgval(e,re,rp)
	local coin=Arcana.GetCoinResult(e:GetHandler())
	if coin==COIN_HEADS then
		return rp==e:GetHandlerPlayer()
	elseif coin==COIN_TAILS then
		return rp~=e:GetHandlerPlayer()
	else
		return false
	end
end
function s.unval(e,te)
	local coin=Arcana.GetCoinResult(e:GetHandler())
	if coin==COIN_HEADS then
		return te:GetOwnerPlayer()==e:GetHandlerPlayer() and te:GetOwner()~=e:GetHandler()
	elseif coin==COIN_TAILS then
		return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
	else
		return false
	end
end