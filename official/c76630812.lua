--天使と悪魔のサイコロ
--Graceful Skull Dice
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Roll a six-sided die twice and apply these effects for the rest of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DICE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(aux.StatChangeDamageStepCondition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	c:RegisterEffect(e1)
	local g=Group.CreateGroup()
	--If your opponent Normal or Special Summons a monster(s) while this card is in your GY: You can banish this card, then target 1 of those monsters; roll a six-sided die twice, and if the total is 6 or more, destroy that monster
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_DICE+CATEGORY_DESTROY)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2a:SetCode(EVENT_CUSTOM+id)
	e2a:SetRange(LOCATION_GRAVE)
	e2a:SetCost(Cost.SelfBanish)
	e2a:SetTarget(s.destg)
	e2a:SetOperation(s.desop)
	e2a:SetLabelObject(g)
	c:RegisterEffect(e2a)
	--Keep track of monsters the opponent Normal or Special Summons
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2b:SetCode(EVENT_SUMMON_SUCCESS)
	e2b:SetRange(LOCATION_GRAVE)
	e2b:SetLabelObject(e2a)
	e2b:SetOperation(s.regop)
	c:RegisterEffect(e2b)
	local e2c=e2b:Clone()
	e2c:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2c)
end
s.listed_names={CARD_DARK_TIME_WIZARD}
s.roll_dice=true
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local d1,d2=Duel.TossDice(tp,2)
	local total_atkdef=(d1+d2)*200
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,2))
	--● Monsters you control that mention "Dark Time Wizard" gain ATK/DEF equal to the total x 200
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetCode(EFFECT_UPDATE_ATTACK)
	e1a:SetTargetRange(LOCATION_MZONE,0)
	e1a:SetTarget(function(e,c) return c:ListsCode(CARD_DARK_TIME_WIZARD) end)
	e1a:SetValue(total_atkdef)
	e1a:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1a,tp)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	Duel.RegisterEffect(e1b,tp)
	aux.RegisterClientHint(c,nil,tp,0,1,aux.Stringid(id,3))
	--● Monsters your opponent controls lose ATK/DEF equal to the total x 200
	local e2a=e1a:Clone()
	e2a:SetTargetRange(0,LOCATION_MZONE)
	e2a:SetTarget(aux.TRUE)
	e2a:SetValue(-total_atkdef)
	Duel.RegisterEffect(e2a,tp)
	local e2b=e2a:Clone()
	e2b:SetCode(EFFECT_UPDATE_DEFENSE)
	Duel.RegisterEffect(e2b,tp)
end
function s.desfilter(c,e,opp)
	return c:IsSummonPlayer(opp) and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_MZONE)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsDamageStep() then return end
	local tg=eg:Filter(s.desfilter,nil,e,1-tp)
	if #tg>0 then
		for tc in tg:Iter() do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		local g=e:GetLabelObject():GetLabelObject()
		if Duel.GetCurrentChain()==0 then g:Clear() end
		g:Merge(tg)
		g:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
		e:GetLabelObject():SetLabelObject(g)
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local opp=1-tp
	local g=e:GetLabelObject():Filter(s.desfilter,nil,e,opp)
	if chkc then return g:IsContains(chkc) and s.desfilter(chkc,e,opp) end
	if chk==0 then return #g>0 end
	local tc=nil
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		tc=g:Select(tp,1,1,nil):GetFirst()
	else
		tc=g:GetFirst()
	end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,2)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,tc,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local d1,d2=Duel.TossDice(tp,2)
		if d1+d2>=6 then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end