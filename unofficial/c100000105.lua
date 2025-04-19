--アルカナフォースＶＩＩＩ－ＳＴＲＥＮＧＴＨ
--Arcana Force VIII - The Strength
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
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.ctop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	Arcana.RegisterCoinResult(c,coin)
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,coin)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--heads
	if Arcana.GetCoinResult(c)==COIN_HEADS and c:GetFlagEffectLabel(id)==1 then
		c:SetFlagEffectLabel(id,0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local g=Duel.SelectMatchingCard(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.HintSelection(g)
			Duel.GetControl(tc,tp)
		end
	end
	--tails
	if Arcana.GetCoinResult(c)==COIN_TAILS and c:GetFlagEffectLabel(id)==0 then
		c:SetFlagEffectLabel(id,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local g=Duel.SelectMatchingCard(1-tp,Card.IsControlerCanBeChanged,1-tp,0,LOCATION_MZONE,1,1,c)
		local tc=g:GetFirst()
		if tc then
			Duel.HintSelection(g)
			Duel.GetControl(tc,1-tp)
		end
	end
end