--交血鬼－ヴァンパイア・シェリダン
--Dhampir Vampire Sheridan
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2+ Level 6 monsters
	Xyz.AddProcedure(c,nil,6,2,nil,nil,Xyz.InfiniteMats)
	--Treat 1 monster you control with a Level owned by your opponent as Level 6 for Xyz Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:HasLevel() and c:GetOwner()~=e:GetHandlerPlayer() end)
	e1:SetValue(s.lvval)
	c:RegisterEffect(e1)
	--Send 1 card your opponent controls to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(Cost.Detach(1,1,nil))
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	--Special Summon 1 monster from your opponent's GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(Cost.Detach(1,1,nil))
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e3:SetLabelObject(g)
	--Keep track of monsters sent to your opponent's GY
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3a:SetCode(EVENT_TO_GRAVE)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetLabelObject(e3)
	e3a:SetOperation(s.regop)
	c:RegisterEffect(e3a)
end
function s.lvval(e,c,rc)
	local lv=c:GetLevel()
	if rc:IsCode(id) then
		return 6
	else
		return lv
	end
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
function s.spfilter(c,e,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsLocation(LOCATION_GRAVE)
		and c:IsControler(1-tp) and c:IsReason(REASON_BATTLE|REASON_EFFECT)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=e:GetLabelObject():Filter(s.spfilter,nil,e,tp)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=e:GetLabelObject()
	if #g==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local sg=g:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
	if #sg>0 then
	Duel.HintSelection(sg)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(s.spfilter,nil,e,tp)
	if #tg>0 then
		for tc in tg:Iter() do
				tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
			end
			local g=e:GetLabelObject():GetLabelObject()
			if Duel.GetCurrentChain()==0 then g:Clear() end
			g:Merge(tg)
			g:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
			e:GetLabelObject():SetLabelObject(g)
			if #g>0 and not Duel.HasFlagEffect(tp,id) then
				Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
				Duel.RaiseEvent(g,EVENT_CUSTOM+id,re,r,tp,ep,ev)
		end
	end
end
