--真紅眼の超越黒竜
--Red-Eyes Black Dragon Exceed
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: "Red-Eyes Black Dragon" + 1 monster that mentions "Dark Time Wizard"
	Fusion.AddProcMix(c,true,true,CARD_REDEYES_B_DRAGON,aux.FilterBoolFunction(Card.ListsCode,CARD_DARK_TIME_WIZARD))
	c:AddMustBeFusionSummoned()
	--Must be either Fusion Summoned, or Special Summoned (from your Extra Deck) by Tributing 1 face-up monster on either field during the turn a monster(s) was destroyed by the effect of "Dark Time Wizard"
	local e0a=Effect.CreateEffect(c)
	e0a:SetDescription(aux.Stringid(id,0))
	e0a:SetType(EFFECT_TYPE_FIELD)
	e0a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0a:SetCode(EFFECT_SPSUMMON_PROC)
	e0a:SetRange(LOCATION_EXTRA)
	e0a:SetCondition(s.selfspcon)
	e0a:SetTarget(s.selfsptg)
	e0a:SetOperation(s.selfspop)
	e0a:SetValue(1)
	c:RegisterEffect(e0a)
	--You can only Special Summon "Red-Eyes Black Dragon Exceed" once per turn this way, no matter which method you use
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0b:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0b:SetCondition(s.regcon)
	e0b:SetOperation(s.regop)
	c:RegisterEffect(e0b)
	--Keep track of a monster being destroyed by the effect of "Dark Time Wizard"
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			if r&REASON_EFFECT>0 and re:GetHandler():IsCode(CARD_DARK_TIME_WIZARD) then
				Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_END,0,1)
			end
		end)
		Duel.RegisterEffect(ge1,0)
	end)
	--If this card is Special Summoned: You can Special Summon 1 Level 8 or lower monster from your hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.lv8sptg)
	e1:SetOperation(s.lv8spop)
	c:RegisterEffect(e1)
	--Unaffected by your opponent's activated monster and Spell effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(function(e,te) return te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and te:IsActivated() and (te:IsMonsterEffect() or te:IsSpellEffect()) end)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_REDEYES_B_DRAGON,CARD_DARK_TIME_WIZARD,id}
s.material={CARD_REDEYES_B_DRAGON}
s.material_setcode={SET_RED_EYES}
function s.selfspcostfilter(c,tp,fc)
	return c:IsReleasable() and c:IsFaceup() and c:IsCanBeFusionMaterial(fc,MATERIAL_FUSION,tp)
		and Duel.GetLocationCountFromEx(tp,tp,c,fc)>0
end
function s.selfspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.HasFlagEffect(0,id) and Duel.CheckReleaseGroup(tp,s.selfspcostfilter,1,false,1,true,c,tp,nil,true,nil,tp,c)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectReleaseGroup(tp,s.selfspcostfilter,1,1,false,true,true,c,tp,nil,true,nil,tp,c)
	if g and #g>0 then
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if g and #g>0 then
		Duel.Release(g,REASON_COST|REASON_MATERIAL)
	end
end
function s.regcon(e)
	local c=e:GetHandler()
	return c:IsFusionSummoned() or c:IsSummonType(SUMMON_TYPE_SPECIAL+1)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	--You can only Special Summon "Red-Eyes Black Dragon Exceed" once per turn this way, no matter which method you use
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype) return c:IsOriginalCodeRule(id) and (sumtype&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION or sumtype&SUMMON_TYPE_SPECIAL+1==SUMMON_TYPE_SPECIAL+1) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.lv8spfilter(c,e,tp)
	return c:IsLevelBelow(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.lv8sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.lv8spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.lv8spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.lv8spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end