--妖精の伝姫
--Fairy Tail
--Scripted by Logical Nonsense and DyXel

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	--Normal summon/set 1 spellcaster monster with 1850 ATK.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(s.nscost)
	e2:SetTarget(s.nstg)
	e2:SetOperation(s.nsop)
	c:RegisterEffect(e2)
	--Each turn, reduce battle or effect damage to 0 the first time.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CHANGE_DAMAGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(1,0)
	e3:SetValue(s.damval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e4:SetCondition(function(e)return e:GetHandler():GetFlagEffect(id)==0 end)
	c:RegisterEffect(e4)
end
	--Check for a spellcaster with 1850 ATK with different name to Normal Summon
function s.nsfilter(c,tp)
	return c:IsAttack(1850) and c:IsRace(RACE_SPELLCASTER) and c:IsSummonable(true,nil) and not c:IsPublic() and
	       not Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,c:GetCode()),tp,LOCATION_MZONE,0,1,nil)
end
	--Reveal a monster that fits filter's requirements as cost
function s.nscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SetTargetCard(g)
end
	--Activation legality
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
	--Normal summon/set the revealed monster
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local s1=tc:IsSummonable(true,nil)
		local s2=tc:IsMSetable(true,nil)
		if (s1 and s2 and Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
			Duel.Summon(tp,tc,true,nil)
		else
			Duel.MSet(tp,tc,true,nil)
		end
	end
end
	--Check for a spellcaster with 1850 ATK
function s.damfilter(c)
	return c:GetBaseAttack()==1850 and c:IsRace(RACE_SPELLCASTER) and c:IsFaceup()
end
function s.damcon(tp)
	return Duel.IsExistingMatchingCard(s.damfilter,tp,LOCATION_MZONE,0,1,nil)
end
	--Check if change was made already once this turn and if not change to 0
function s.damval(e,re,val,r,rp,rc)
	local tp=e:GetHandlerPlayer()
	local c=e:GetHandler()
	if r&(REASON_BATTLE|REASON_EFFECT)~=0 and c:GetFlagEffect(id)==0 and s.damcon(tp) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		Duel.Hint(HINT_CARD,0,id)
		return 0
	end
	return val
end
