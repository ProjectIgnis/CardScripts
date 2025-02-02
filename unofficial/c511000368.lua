--Ｎｏ．９２ 偽骸神龍 Ｈｅａｒｔ－ｅａｒｔＨ Ｄｒａｇｏｎ (Anime)
--Number 92: Heart-eartH Dragon (Anime)
Duel.LoadCardScript("c97403510.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 9 monsters
	Xyz.AddProcedure(c,nil,9,3)
	--Cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Change all monsters your opponent controls to Defense Position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	--Banish all cards placed on your opponent's field 
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	--Battle damage from battles involving this card becomes 0
    	local e4=Effect.CreateEffect(c)
    	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    	e4:SetCode(EVENT_PRE_BATTLE_DAMAGE)
    	e4:SetRange(LOCATION_MZONE)
    	e4:SetOperation(s.battledamageop)
    	c:RegisterEffect(e4)
    	--Inflict damage to your opponent equal to the battle damage you would have taken, then gain LP equal to that amount
    	local e5=Effect.CreateEffect(c)
    	e5:SetDescription(aux.Stringid(id,2))
    	e5:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER)
    	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    	e5:SetCode(EVENT_BATTLED)
    	e5:SetRange(LOCATION_MZONE)
    	e5:SetLabelObject(e4)
    	e5:SetTarget(s.damrectg)
    	e5:SetOperation(s.damrecop)
    	c:RegisterEffect(e5)
	--Special Summon this card from the GY
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,3))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetCost(s.spcost)
	e6:SetCondition(s.spcon)
	e6:SetTarget(s.sptg)
	e6:SetOperation(s.spop)
	c:RegisterEffect(e6)
	--Gains 1000 ATK for each banished card if it's Special Summoned by its own effect
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,4))
	e7:SetCategory(CATEGORY_ATKCHANGE)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_UPDATE_ATTACK)
	e7:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1) end)
	e7:SetValue(function(e,c) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_REMOVED,LOCATION_REMOVED)*1000 end)
	c:RegisterEffect(e7)
end
s.xyz_number=92
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
    	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAttackPos,tp,0,LOCATION_MZONE,1,nil) end
    	local g=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
    	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    	local g=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
    	if Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,0,0,true)>0 then
		local og=Duel.GetOperatedGroup()
		for tc in og:Iter() do
			--Cannot change their battle positions
			local e1=Effect.CreateEffect(e:GetHandler())
            		e1:SetDescription(3313)
            		e1:SetType(EFFECT_TYPE_SINGLE)
            		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
            		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
            		tc:RegisterEffect(e1)
        	end
    	end
end
function s.rmfilter(c,turn)
    	return c:IsAbleToRemove() and c:GetTurnID()~=turn
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_ONFIELD,1,nil,Duel.GetTurnCount()) end
    	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_ONFIELD,nil,Duel.GetTurnCount())
    	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_ONFIELD,nil,Duel.GetTurnCount())
    	if #g>0 then
        	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    	end
end
function s.battledamageop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,0)
	e:SetLabel(ev)
end
function s.damrectg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dam=e:GetLabelObject():GetLabel()
	if chk==0 then return dam>0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,dam)
end
function s.damrecop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Damage(p,d,REASON_EFFECT) then
		Duel.Recover(tp,d,REASON_EFFECT)
	end
	e:GetLabelObject():SetLabel(0)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    	local c=e:GetHandler()
    	if chk==0 then return c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,0,0,1)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    	local c=e:GetHandler()
    	return c:IsReason(REASON_DESTROY) and e:GetHandler():GetOverlayCount()==0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    	local c=e:GetHandler()
    	if chk==0 then return c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        	and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    	local c=e:GetHandler()
    	if c:IsRelateToEffect(e) then
        	Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)
    	end
end
