--グリード・クエーサー (Manga)
--Greed Quasar (Manga)
local s,id=GetID()
function s.initial_effect(c)
	--Gains 300 ATK/DEF for each Life Star Counter on this card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(_,c) return c:GetCounter(0x1109)*300 end)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e2)
	--Add Life Star Counters to this card from monsters it destroys by battle
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_LEAVE_FIELD_P)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.ctcon)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToBattle() and c:IsFaceup()) then return false end
	local bc=c:GetBattleTarget()
	if not bc then return false end
	local ct=bc:GetCounter(0x1109)
	return ct>0 and c:IsCanAddCounter(0x1109,ct)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local ct=bc:GetCounter(0x1109)
	local count=0
	if bc and bc:IsReason(REASON_BATTLE) and bc:GetReasonCard()==c then
		count=count+ct
	end
	if count>0 then
		Duel.Hint(HINT_CARD,0,id)
		c:AddCounter(0x1109,count)
	end
end