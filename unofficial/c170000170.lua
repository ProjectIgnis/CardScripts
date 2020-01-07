--Divine Serpent Geh (Anime)
--updated infinity ATK handling by Larry126
--fixed Attack Cost by Larry126
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--infinite
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	--spsummon success
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(s.sucop)
	c:RegisterEffect(e4)
	--attack cost
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_ATTACK_COST)
	e5:SetCost(s.atcost)
	e5:SetOperation(s.atop)
	c:RegisterEffect(e5)
	--
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e8:SetCode(EFFECT_CANNOT_LOSE_LP)
	e8:SetRange(LOCATION_MZONE)
	e8:SetTargetRange(1,0)
	e8:SetValue(1)
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetCode(EFFECT_CANNOT_LOSE_DECK)
	c:RegisterEffect(e9)
	local e10=e8:Clone()
	e10:SetCode(EFFECT_CANNOT_LOSE_EFFECT)
	c:RegisterEffect(e10)
	--atk
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_SINGLE)
	e11:SetCode(EFFECT_UPDATE_ATTACK)
	e11:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e11:SetRange(LOCATION_MZONE)
	e11:SetValue(s.adval)
	c:RegisterEffect(e11)
	aux.GlobalCheck(s,function()
		--avatar
		local av=Effect.CreateEffect(c)
		av:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		av:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		av:SetCode(EVENT_ADJUST)
		av:SetCondition(s.avatarcon)
		av:SetOperation(s.avatarop)
		Duel.RegisterEffect(av,0)
	end)
end
s.listed_names={21208154}
function s.avfilter(c)
	local atktes={c:GetCardEffect(EFFECT_SET_ATTACK_FINAL)}
	local ae=nil
	local de=nil
	for _,atkte in ipairs(atktes) do
		if atkte:GetOwner()==c and atkte:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_REPEAT+EFFECT_FLAG_DELAY) then
			ae=atkte:GetLabel()
		end
	end
	local deftes={c:GetCardEffect(EFFECT_SET_DEFENSE_FINAL)}
	for _,defte in ipairs(deftes) do
		if defte:GetOwner()==c and defte:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_REPEAT+EFFECT_FLAG_DELAY) then
			de=defte:GetLabel()
		end
	end
	return c:IsOriginalCode(21208154) and (ae~=9999999 or de~=9999999)
end
function s.avatarcon(e,tp,eg,ev,ep,re,r,rp)
	return Duel.IsExistingMatchingCard(s.avfilter,tp,0xff,0xff,1,nil)
end
function s.avatarop(e,tp,eg,ev,ep,re,r,rp)
	local g=Duel.GetMatchingGroup(s.avfilter,tp,0xff,0xff,nil)
	g:ForEach(function(c)
		local atktes={c:GetCardEffect(EFFECT_SET_ATTACK_FINAL)}
		for _,atkte in ipairs(atktes) do
			if atkte:GetOwner()==c and atkte:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_REPEAT+EFFECT_FLAG_DELAY) then
				atkte:SetValue(s.avaval)
				atkte:SetLabel(9999999)
			end
		end
		local deftes={c:GetCardEffect(EFFECT_SET_DEFENSE_FINAL)}
		for _,defte in ipairs(deftes) do
			if defte:GetOwner()==c and defte:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_REPEAT+EFFECT_FLAG_DELAY) then
				defte:SetValue(s.avaval)
				defte:SetLabel(9999999)
			end
		end
	end)
end
function s.avafilter(c)
	return c:IsFaceup() and c:GetCode()~=21208154
end
function s.avaval(e,c)
	local g=Duel.GetMatchingGroup(s.avafilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then 
		return 100
	else
		local tg,val=g:GetMaxGroup(Card.GetAttack)
		if val>=9999999 then
			return val
		else
			return val+100
		end
	end
end
-------------------------------------------------------------------
function s.sucop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	Duel.SendtoGrave(g,REASON_EFFECT)
	Duel.SetLP(tp,0)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and e:GetHandler():GetAttack()>=9999999
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,Duel.GetLP(ep)*100)
end
function s.atcost(e,c,tp)
	return Duel.IsPlayerCanDiscardDeckAsCost(tp,10)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsAttackCostPaid()~=2 and e:GetHandler():IsLocation(LOCATION_MZONE) then
		Duel.DiscardDeck(tp,10,REASON_COST)
		Duel.AttackCostPaid()
	end
end
function s.adval(e,c)
	local g=Duel.GetMatchingGroup(nil,0,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if #g==0 then 
		return 9999999
	else
		local tg,val=g:GetMaxGroup(Card.GetAttack)
		if val<=9999999 then
			return 9999999
		else
			return val
		end
	end
end