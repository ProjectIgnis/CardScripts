--アルカナフォースＸＶ－ＴＨＥ　ＤＥＶＩＬ
--Arcana Force XV - The Fiend
local s,id=GetID()
function s.initial_effect(c)
	--coin
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.cointg)
	e1:SetOperation(s.coinop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
s.toss_coin=true
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
	--coin effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	Arcana.RegisterCoinResult(c,coin)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local coin=Arcana.GetCoinResult(e:GetHandler())
	if chk==0 then return coin==COIN_HEADS or coin==COIN_TAILS end
	local heads=coin==COIN_HEADS
	if heads then
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	else
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(0)
	end
	if chkc then return heads and chkc:IsLocation(LOCATION_MZONE) end
	if heads then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,g:GetFirst():GetControler(),500)
	else
		local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	end
	Duel.SetTargetParam(coin)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local coin=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if coin==COIN_HEADS then
		local tc=Duel.GetFirstTarget()
		if tc then
			if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
				Duel.Damage(tc:GetPreviousControler(),500,REASON_EFFECT)
			elseif e:GetHandler():IsRelateToEffect(e) then
				Duel.Destroy(e:GetHandler(),REASON_EFFECT)
			end
		end
	elseif coin==COIN_TAILS then
		local sg=Duel.GetMatchingGroup(Card.IsDestructable,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end