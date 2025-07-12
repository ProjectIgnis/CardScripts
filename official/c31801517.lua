--Ｎｏ．６２ 銀河眼の光子竜皇
--Number 62: Galaxy-Eyes Prime Photon Dragon
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 8 monsters
	Xyz.AddProcedure(c,nil,8,2)
	--This card gains ATK equal to the combined Ranks of all Xyz Monsters currently on the field x 200
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return e:GetHandler():IsRelateToBattle() end)
	e1:SetCost(Cost.AND(Cost.DetachFromSelf(1),Cost.SoftOncePerBattle(id)))
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--Special Summon this card during your 2nd Standby Phase after activation and double its ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Any battle damage this card inflicts to your opponent is halved unless it has "Galaxy-Eyes Photon Dragon" as material
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetCondition(function(e) return not e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,CARD_GALAXYEYES_P_DRAGON) end)
	e3:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e3)
end
s.xyz_number=62
s.listed_names={CARD_GALAXYEYES_P_DRAGON}
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local rks=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil):GetSum(Card.GetRank)
		if rks>0 then
			--This card gains ATK equal to the combined Ranks of all Xyz Monsters currently on the field x 200, during that damage calculation only
			c:UpdateAttack(rks*200,RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_DAMAGE_CAL)
		end
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,CARD_GALAXYEYES_P_DRAGON)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:SetTurnCounter(0)
		local turn_count=Duel.GetTurnCount()
		local reset_count=(Duel.IsPhase(PHASE_STANDBY) and Duel.IsTurnPlayer(tp)) and 3 or 2
		--Special Summon this card during your 2nd Standby Phase after activation
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetRange(c:GetLocation())
		e1:SetCountLimit(1)
		e1:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) and (reset_count==2 or Duel.GetTurnCount()~=turn_count) end)
		e1:SetOperation(s.standbyspop)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_STANDBY|RESET_SELF_TURN,reset_count)
		c:RegisterEffect(e1)
	end
end
function s.standbyspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()+1
	c:SetTurnCounter(ct)
	if ct==2 and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		--Double its ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end
