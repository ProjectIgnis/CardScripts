--武闘円舞 (Anime)
--Battle Waltz (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,15629802,0,TYPES_TOKEN,c:GetAttack(),c:GetDefense(),c:GetLevel(),c:GetRace(),c:GetAttribute())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,15629802,0,TYPES_TOKEN,tc:GetAttack(),tc:GetDefense(),tc:GetLevel(),tc:GetRace(),tc:GetAttribute()) then return end
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
	        local token=Duel.CreateToken(tp,15629802)
	        local e1=Effect.CreateEffect(e:GetHandler())
	        e1:SetType(EFFECT_TYPE_SINGLE)
	        e1:SetCode(EFFECT_SET_BASE_ATTACK)
	        e1:SetValue(tc:GetAttack())
	        e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TOFIELD)
	        token:RegisterEffect(e1)
	        local e2=e1:Clone()
	        e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	        e2:SetValue(tc:GetDefense())
	        token:RegisterEffect(e2)
	        local e3=e1:Clone()
	        e3:SetCode(EFFECT_CHANGE_LEVEL)
	        e3:SetValue(tc:GetLevel())
	        token:RegisterEffect(e3)
	        local e4=e1:Clone()
	        e4:SetCode(EFFECT_CHANGE_RACE)
	        e4:SetValue(tc:GetRace())
	        token:RegisterEffect(e4)
	        local e5=e1:Clone()
	        e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	        e5:SetValue(tc:GetAttribute())
	        token:RegisterEffect(e5)
                if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
		        --No battle damage
                        local e6=Effect.CreateEffect(e:GetHandler())
	                e6:SetType(EFFECT_TYPE_SINGLE)
	                e6:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	                e6:SetValue(1)
	                e6:SetReset(RESET_EVENT|RESETS_STANDARD)
	                token:RegisterEffect(e6)
	                local e7=e6:Clone()
	                e7:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	                token:RegisterEffect(e7)
			--Lower ATK if destroyed by battle
	                local e8=Effect.CreateEffect(e:GetHandler())
	                e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	                e8:SetCode(EVENT_BATTLE_DESTROYED)
	                e8:SetOperation(s.desop)
	                e8:SetReset(RESET_EVENT|RESETS_CANNOT_ACT|RESET_PHASE|PHASE_END)
	                token:RegisterEffect(e8)
		end
	        Duel.SpecialSummonComplete()
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if c==tc then tc=Duel.GetAttackTarget() end
	if not tc or not tc:IsRelateToBattle() then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	e1:SetValue(-c:GetPreviousAttackOnField())
	tc:RegisterEffect(e1)
end
