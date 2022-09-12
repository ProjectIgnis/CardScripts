--スプリガンズ・ブラスト！
--Sprigguns Blast!
--scripted by aforaverage.46
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x158}
s.listed_names={CARD_ALBAZ}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x158),tp,LOCATION_MZONE,0,1,nil)
end
function s.bonusfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:ListsCodeAsMaterial(CARD_ALBAZ)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	local seqs={}
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local zone1=Duel.SelectFieldZone(tp,1,0,LOCATION_MZONE,0x60<<16)
	table.insert(seqs, math.log(zone1,2)-16)
	Duel.Hint(HINT_ZONE,tp,zone1)
	if Duel.IsExistingMatchingCard(s.bonusfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
		local zone2=Duel.SelectFieldZone(tp,1,0,LOCATION_MZONE,(0x60<<16)|zone1)
		table.insert(seqs, math.log(zone2,2)-16)
		Duel.Hint(HINT_ZONE,tp,zone2)
	end
	e:SetLabel(table.unpack(seqs))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local s1,s2=e:GetLabel()
	local z1=Duel.GetFieldCard(1-tp,LOCATION_MZONE,s1)
	if z1 and z1:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		z1:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		z1:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		z1:RegisterEffect(e3)
	elseif z1==nil then
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_DISABLE_FIELD)
		e4:SetValue((1<<s1)<<((1-tp)*16))
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e4,tp)
	end
	if s2 then
		local z2=Duel.GetFieldCard(1-tp,LOCATION_MZONE,s2)
		if z2 and z2:IsFaceup() then
			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_SINGLE)
			e5:SetCode(EFFECT_DISABLE)
			e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			z2:RegisterEffect(e5)
			local e6=Effect.CreateEffect(c)
			e6:SetType(EFFECT_TYPE_SINGLE)
			e6:SetCode(EFFECT_DISABLE_EFFECT)
			e6:SetValue(RESET_TURN_SET)
			e6:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			z2:RegisterEffect(e6)
			local e7=Effect.CreateEffect(c)
			e7:SetType(EFFECT_TYPE_SINGLE)
			e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e7:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			e7:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			z2:RegisterEffect(e7)
		elseif z2==nil then
			local e8=Effect.CreateEffect(c)
			e8:SetType(EFFECT_TYPE_FIELD)
			e8:SetCode(EFFECT_DISABLE_FIELD)
			e8:SetValue((1<<s2)<<((1-tp)*16))
			e8:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e8,tp)
		end
	end
end
