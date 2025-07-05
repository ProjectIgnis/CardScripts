--ＣＮｏ．７３ 激瀧瀑神アビス・スープラ
--Number C73: Abyss Supra Splash
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 6 monsters
	Xyz.AddProcedure(c,nil,6,3)
	--Your battling monster gains ATK equal to the ATK of the opponent's monster it is battling, during that damage calculation only
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.atkcon)
	e1:SetCost(Cost.AND(Cost.Detach(1),Cost.SoftOncePerBattle(id)))
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--This card cannot be destroyed by card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e) return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,36076683) end)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
s.xyz_number=73
s.listed_names={36076683} --"Number C73: Abyss Supra Splash"
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local a,b=Duel.GetBattleMonster(tp)
	return a and b and a:GetControler()~=b:GetControler()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local a,b=Duel.GetBattleMonster(tp)
	if a:IsRelateToBattle() and a:IsFaceup() and b:IsRelateToBattle() and b:IsFaceup() then
		a:UpdateAttack(b:GetAttack(),RESET_PHASE|PHASE_DAMAGE_CAL,e:GetHandler())
	end
end
