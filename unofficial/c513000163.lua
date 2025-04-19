--アルカナフォースＸＩＩ－ＴＨＥ ＨＡＮＧＥＤ ＭＡＮ (Anime)
--Arcana Force XII - The Hangman (Anime)
--Scripted GameMaster(GM)
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
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,2))
	e0:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCountLimit(1)
	e0:SetCondition(s.descon)
	e0:SetTarget(s.destg)
	e0:SetOperation(s.desop)
	e0:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e0)
	--coin effect if not used in Main Phase
	local e1=e0:Clone()
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCondition(s.epcon)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	Arcana.RegisterCoinResult(c,coin)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer()
end
function s.epcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer() and Duel.GetFlagEffect(tp,id)==0
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	--self
	local coin=Arcana.GetCoinResult(e:GetHandler())
	if coin==COIN_HEADS then
		if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
		local c=e:GetHandler()
		if chk==0 then return true end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,Card.IsMonster,tp,LOCATION_MZONE,0,1,1,nil)
		local atk=g:GetFirst():GetAttack()
		Duel.SetTargetPlayer(tp)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,atk)
		Duel.RegisterFlagEffect(tp,id,RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
	elseif coin==COIN_TAILS then
	--opponents
		if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
		local c=e:GetHandler()
		if chk==0 then return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,Card.IsMonster,tp,0,LOCATION_MZONE,1,1,nil)
		local atk=g:GetFirst():GetAttack()
		Duel.SetTargetPlayer(1-tp)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
		Duel.RegisterFlagEffect(tp,id,RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local atk=tc:GetAttack()
		Duel.Damage(p,atk,REASON_EFFECT)
	end
end