--No.39 希望皇ホープ・ルーツ (Anime)
--Number 39: Utopia Roots (Anime)
Duel.LoadCardScript(84124261)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 1 monsters
	Xyz.AddProcedure(c,nil,1,2)
	--Cannot be destroyed by battle, except with "Number" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,SET_NUMBER)))
	c:RegisterEffect(e1)
	--Attach 1 Xyz Material from this card to 1 Xyz monster your opponent controls, then this card's ATK becomes equal to the difference in Ranks between this card and that oppponent's monster, multiplied by the number of materials attached 1 Xyz Monster your controls
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetCost(Cost.DetachFromSelf(1,1,function(e,og) Duel.Overlay(e:GetHandler():GetBattleTarget(),og) end))
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NUMBER}
s.xyz_number=39
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsXyzMonster() and bc:IsFaceup() and bc:IsControler(1-tp)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(e:GetHandler():GetBattleTarget())
end
function s.overlayfilter(c)
	return c:GetOverlayCount()>0
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		if Duel.GetAttacker()==c then Duel.NegateAttack() end
		local to=Duel.SelectMatchingCard(tp,s.overlayfilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
		local toc=1
		local toc=to:GetOverlayCount()
		local atk=math.abs(((tc:GetRank()-c:GetRank())*100)*toc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
		c:RegisterEffect(e1)
	end
end
