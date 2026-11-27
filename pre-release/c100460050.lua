--ゴーストリック・リッチー
--Ghostrick Lich
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be Normal Summoned, unless you control a "Ghostrick" monster
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_SUMMON)
	e0:SetCondition(function(e)
		return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_GHOSTRICK),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
	end)
	c:RegisterEffect(e0)
	--If this card is Normal Summoned or flipped face-up: Set 1 "Ghostrick" Quick-Play Spell or "Ghostrick" Normal Trap from your Deck (it can be activated this turn), also you cannot Special Summon for the rest of this turn, except DARK monsters. You can only use this effect of "Ghostrick Lich" once per turn
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_SET)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetCountLimit(1,id)
	e1a:SetTarget(s.settg)
	e1a:SetOperation(s.setop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_FLIP)
	c:RegisterEffect(e1b)
	--Once per turn: You can change this card to face-down Defense Position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GHOSTRICK}
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK)
end
function s.setfilter(c)
	return c:IsSetCard(SET_GHOSTRICK) and (c:IsQuickPlaySpell() or c:IsNormalTrap()) and c:IsSSetable()
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local sc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if sc and Duel.SSet(tp,sc)>0 then
		local eff_code=sc:IsQuickPlaySpell() and EFFECT_QP_ACT_IN_SET_TURN or EFFECT_TRAP_ACT_IN_SET_TURN
		--It can be activated this turn
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(eff_code)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		sc:RegisterEffect(e1)
	end
	--You cannot Special Summon for the rest of this turn, except DARK monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(e,c)
		return c:IsAttributeExcept(ATTRIBUTE_DARK)
	end)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and not c:HasFlagEffect(id) end
	c:RegisterFlagEffect(id,RESET_EVENT|(RESETS_STANDARD_PHASE_END&~RESET_TURN_SET),0,1)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,tp,POS_FACEDOWN_DEFENSE)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end