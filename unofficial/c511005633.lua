--光の結界 (Anime)
--Light Barrier (Anime)
--scripted by GameMaster(GM), fixed by MLD and Larry126
local s,id,alias=GetID()
function s.initial_effect(c)
	alias=c:GetOriginalCodeRule()
	--Toss a coin when this card is activated
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.cointg)
	e1:SetOperation(s.coinop)
	c:RegisterEffect(e1)
	--Toss a coin during your Standby Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(alias,0))
	e2:SetCategory(CATEGORY_COIN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(function(_,tp) return Duel.IsTurnPlayer(tp) end)
	e2:SetTarget(s.cointg)
	e2:SetOperation(s.coinop)
	c:RegisterEffect(e2)
	--Apply the "Light Barrier" effect to the player
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(CARD_LIGHT_BARRIER)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,1)
	e3:SetCondition(s.effectcon)
	c:RegisterEffect(e3)
	--Gain LP if a monster destroys another monster by battle
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(alias,1))
	e4:SetCategory(CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetCondition(s.reccon)
	e4:SetTarget(s.rectg)
	e4:SetOperation(s.recop)
	c:RegisterEffect(e4)
	--Negate the effects of all non-"Arcana Force" monsters on the field
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_DISABLE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetCondition(s.effectcon)
	e5:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,SET_ARCANA_FORCE)))
	c:RegisterEffect(e5)
end
s.listed_series={SET_ARCANA_FORCE}
s.toss_coin=true
function s.effectcon(e)
	local c=e:GetHandler()
	return c:GetFlagEffect(alias+1)==0 or c:IsHasEffect(EFFECT_CANNOT_DISABLE)
end
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.TossCoin(tp,1)==COIN_TAILS then
		c:RegisterFlagEffect(alias+1,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_STANDBY|RESET_SELF_TURN,0,2)
	end
end
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=eg:GetFirst()
	return rc:IsRelateToBattle() and rc:IsFaceup() and not rc:GetBattleTarget():IsControler(rc:GetControler()) 
		and (c:GetFlagEffect(alias+1)==0 or c:IsHasEffect(EFFECT_CANNOT_DISABLE))
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local p=eg:GetFirst():GetControler()
	local atk=eg:GetFirst():GetBattleTarget():GetBaseAttack()
	if atk<0 then atk=0 end
	Duel.SetTargetPlayer(p)
	Duel.SetTargetParam(atk)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,p,atk)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end