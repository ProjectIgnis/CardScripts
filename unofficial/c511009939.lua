--転生炎獣の散火
--Salamangreat Sparks
local s,id=GetID()
local TOKEN_SALAMANGREAT=id+1
function s.initial_effect(c)
	--Equip only to a Cyberse Link Monster
	aux.AddEquipProcedure(c,nil,function(c) return c:IsRace(RACE_CYBERSE) and c:IsLinkMonster() end)
	--If it battles an opponent's monster, its ATK becomes equal to the current ATK of the opponent's monster it is battling, during damage calculation only
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetCondition(s.atkcon)
	e1:SetValue(function(e,c) return e:GetHandler():GetEquipTarget():GetBattleTarget():GetAttack() end)
	c:RegisterEffect(e1)	
	--Special Summon up to 2 "Salamangreat Tokens" in Defense Position to either player's field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tokencon)
	e2:SetTarget(s.tokentg)
	e2:SetOperation(s.tokenop)
	c:RegisterEffect(e2)
end
s.listed_names={TOKEN_SALAMANGREAT}
function s.atkcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	if not (Duel.IsPhase(PHASE_DAMAGE_CAL) and ec) then return false end
	local bc=ec:GetBattleTarget()
	return ec:IsRelateToBattle() and bc and bc:IsControler(1-e:GetHandlerPlayer())
end
function s.tokencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_DESTROY) 
end
function s.cansstoken(sum_p,targ_p)
	return Duel.GetLocationCount(targ_p,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(sum_p,TOKEN_SALAMANGREAT,SET_SALAMANGREAT,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_FIRE,POS_FACEUP_DEFENSE,targ_p)
end
function s.tokentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.cansstoken(tp,tp) or s.cansstoken(tp,1-tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
function s.tokenop(e,tp,eg,ep,ev,re,r,rp)
	local b1=s.cansstoken(tp,tp)
	local b2=s.cansstoken(tp,1-tp)
	if not (b1 or b2) then return end
	local ft1=b1 and Duel.GetLocationCount(tp,LOCATION_MZONE) or 0
	local ft2=b2 and Duel.GetLocationCount(1-tp,LOCATION_MZONE) or 0
	local total_ft=ft1+ft2
	local ct=math.min(total_ft,2)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct=1 end
	ct=ct==2 and Duel.AnnounceNumberRange(tp,1,ct) or 1
	for i=1,ct do
		local op=nil
		if b1 and b2 and not (ct==2 and total_ft==2) then
			op=Duel.SelectEffect(tp,
				{b1,aux.Stringid(id,2)},
				{b2,aux.Stringid(id,3)})
		else
			op=(b1 and 1) or (b2 and 2)
		end
		local targ_p=op==1 and tp or 1-tp
		local token=Duel.CreateToken(tp,TOKEN_SALAMANGREAT)
		Duel.SpecialSummonStep(token,0,tp,targ_p,false,false,POS_FACEUP_DEFENSE)
		if ct==1 or i==2 then break end
		b1=s.cansstoken(tp,tp)
		b2=s.cansstoken(tp,1-tp)
	end
	Duel.SpecialSummonComplete()
end