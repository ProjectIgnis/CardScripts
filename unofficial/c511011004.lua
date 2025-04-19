--死神の巡遊 (Anime)
--Tour of Doom (Anime)
--Updated by GameMaster(GM) & MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE)
	c:RegisterEffect(e1)
	--coin
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COIN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(s.coincon)
	e2:SetTarget(s.cointg)
	e2:SetOperation(s.coinop)
	c:RegisterEffect(e2)
end
s.toss_coin=true
function s.coincon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local function register_eff(player)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		if player==tp then
			e1:SetReset(RESET_PHASE+PHASE_END,2)
			e1:SetTargetRange(1,0)
			local cur_turn=Duel.GetTurnCount()
			e1:SetCondition(function()return Duel.GetTurnCount()~=cur_turn end)
		else
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetTargetRange(0,1)
		end
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
		Duel.RegisterEffect(e2,tp)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		Duel.RegisterEffect(e3,tp)
	end
	local res=Duel.TossCoin(tp,1)
	if res==COIN_HEADS then
		register_eff(1-tp)
	elseif res==COIN_TAILS then
		register_eff(tp)
	end
end