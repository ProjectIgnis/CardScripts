--アサルト・リオン
--Assault Lion
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--You can Tribute Summon this card face-up by Tributing 1 Beast-Warrior monster
	aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),s.tribfilter)
	--If this card battles a monster, any battle damage it inflicts to your opponent is doubled
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetCondition(function(e) return e:GetHandler():GetBattleTarget() end)
	e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e1)
	--If a Beast-Warrior monster(s) is Normal or Special Summoned to your field while this card is in your GY: You can add this card to your hand, then immediately after this effect resolves, you can Tribute Summon this card face-up, and if you do, it gains 500 ATK, also banish it when it leaves the field
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_TOHAND+CATEGORY_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_REMOVE)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2a:SetCode(EVENT_SUMMON_SUCCESS)
	e2a:SetRange(LOCATION_GRAVE)
	e2a:SetCountLimit(1,id)
	e2a:SetCondition(s.thcon)
	e2a:SetTarget(s.thtg)
	e2a:SetOperation(s.thop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
end
function s.tribfilter(c,tp)
	return c:IsRace(RACE_BEASTWARRIOR) and (c:IsControler(tp) or c:IsFaceup())
end
function s.thconfilter(c,tp)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsControler(tp) and c:IsFaceup()
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.thconfilter,1,nil,tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0 and c:IsLocation(LOCATION_HAND) then
		Duel.ShuffleHand(tp)
		if c:IsSummonable(true,nil,1) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Summon(tp,c,true,nil,1)
			--It gains 500 ATK
			c:UpdateAttack(500,RESET_EVENT|(RESETS_STANDARD_DISABLE&~RESET_TOFIELD))
			--Also banish it when it leaves the field
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3300)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
			c:RegisterEffect(e1)
		end
	end
end