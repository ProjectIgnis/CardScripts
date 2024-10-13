--多層融合
--Heavy Polymerization
--Scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	Fusion.RegisterSummonEff{handler=c,mincount=3,extrafil=s.fextra,extratg=s.extratg,extraop=s.extraop,stage2=s.stage2}
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
end
function s.fextra(e,tp,mg)
	local eg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_EXTRA,0,nil)
	if #eg>0 then
		return eg,s.fcheck
	end
	return nil
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
		e:SetLabel(rg:GetSum(Card.GetAttack))
		sg:Sub(rg)
	else
		e:SetLabel(0)
	end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_EXTRA)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==0 then
		local ct=e:GetLabel()
		if ct>0 then
			Duel.SetLP(tp,Duel.GetLP(tp)-ct)
		end
	end
end