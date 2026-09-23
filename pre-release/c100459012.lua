--ゾンバイア
--Zombyra
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--When this card declares an attack: You lose 500 LP, and if you do, this card gains 500 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local lp=Duel.GetLP(tp)
		Duel.SetLP(tp,lp-500)
		if Duel.GetLP(tp)<lp then
			--You lose 500 LP, and if you do, this card gains 500 ATK
			e:GetHandler():UpdateAttack(500)
		end
	end)
	c:RegisterEffect(e1)
	--When a monster is destroyed by battle: You can equip this card from your GY to the monster that destroyed that monster, then you can destroy the 1 monster your opponent controls with the highest ATK (your choice, if tied)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return not eg:IsContains(e:GetHandler())
	end)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	--The equipped monster's name becomes "Zombyra", also its effects are negated
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_EQUIP)
	e3a:SetCode(EFFECT_CHANGE_CODE)
	e3a:SetValue(id)
	c:RegisterEffect(e3a)
	local e3b=e3a:Clone()
	e3b:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e3b)
	--When the equipped monster declares an attack: Its controller loses 500 LP, and if they do, the equipped monster gains 500 ATK
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		return c:IsEquipSpell() and c:GetEquipTarget()==eg:GetFirst()
	end)
	e4:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local bc=c:GetEquipTarget()
		if not bc then return end
		local cntrl=bc:GetControler()
		local lp=Duel.GetLP(cntrl)
		Duel.SetLP(cntrl,lp-500)
		if Duel.GetLP(cntrl)<lp then
			--Its controller loses 500 LP, and if they do, the equipped monster gains 500 ATK
			bc:UpdateAttack(500,RESET_EVENT|RESETS_STANDARD,c)
		end
	end)
	c:RegisterEffect(e4)
end
s.listed_names={id}
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and eg:GetFirst():GetBattleTarget():IsRelateToBattle() end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=eg:GetFirst():GetBattleTarget()
	if c:IsRelateToEffect(e) and bc:IsRelateToBattle() and Duel.Equip(tp,c,bc,true) then
		--Equip limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetValue(function(e,c) return c==bc end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
		if Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			local dg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil):GetMaxGroup(Card.GetAttack)
			if #dg>1 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				dg=dg:Select(tp,1,1,nil)
				Duel.HintSelection(dg)
			end
			if #dg>0 then
				Duel.BreakEffect()
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
	end
end